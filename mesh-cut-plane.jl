# cut a mesh at a plane.

if length(ARGS)<7
  println("Usage: mesh-cut-plane <a> <b> <c> <d> <flipfaces=true|false> <input.off> <output.off>")
	println("where a,b,c,d define the linear equation corresponding to the plane:")
	println("ax + by + cz + d = 0")
	exit()
end

pln_a = parse(Float64, ARGS[1])
pln_b = parse(Float64, ARGS[2])
pln_c = parse(Float64, ARGS[3])
pln_d = parse(Float64, ARGS[4])
flipf = convert(Bool, parse(ARGS[5]))
infile = ARGS[6]
outfile = ARGS[7]

println("$(pln_a)x + $(pln_b)y + $(pln_c)z + $pln_d = 0")

# compute plane transformation
v = [pln_a,pln_b,pln_c]
u0 = vec(-pinv(v)*pln_d)  # compute a point on the plane (offset)
v  = v/norm(v)
q  = inv(svd([0., 0., 1.0]*pinv(v))[3]) # compute a transformation that straightens normal vector
q = flipdim(q,1)

flipz=false
if sum(q*v) < 0
	flipz=true
	q=-q
end

using ImmutableArrays
using GeometryTypes
include("../OFF.jl")
include("triangle-io.jl")

typealias Vtx{T} ImmutableArrays.Vector3{T}

prjxy(p::Vector3) = Vector3(p.e1,p.e2,0.0)
# intersect line with z=0 plane;
function lin_plane_intrsct{T}(p1::Vector3{T}, p2::Vector3{T})
	t = p1.e3/(p1.e3-p2.e3)
	(0.0 < t) && (t < 1.0) ? prjxy(p1+t*(p2-p1)) : nothing
end

# intersection of triangle with z=0 plane;
# produces 6 points p1,p2,p3,p4,p5,p6
# with 4 triangles
# also returns the (correctly oriented) edge that lies on z=0
function tri_plane_cut!{T}(verts::Array{Vtx{T}}, n_orig_vert, i1, i2, i3)
	local o_edge
	
	it = Union{Vector3,Void}[
	      lin_plane_intrsct(verts[i1], verts[i2]),
	      lin_plane_intrsct(verts[i2], verts[i3]),
		  lin_plane_intrsct(verts[i3], verts[i1])]

	# add intersection point with default idx fallback;
	# that is, if crd==nothing (no intersection point)
	# return idx instead
	# also sets the output edge
	function add_intersection_point!{T}(verts::Array{Vtx{T}}, i, idx)
		if it[i]==nothing
			if i==1; o_edge=(2,3); end
			if i==2; o_edge=(3,1); end
			if i==3; o_edge=(1,2); end
			return idx
		else
			# add vertex; making sure it's not a duplicate
			p = it[i]
			tol = 1e-6
			is_dup=false
			for i = n_orig_vert+1 : length(verts)
				if (abs(verts[i].e1 - p.e1) < tol) &&
				   (abs(verts[i].e2 - p.e2) < tol) &&
				   (abs(verts[i].e3 - p.e3) < tol)
					is_dup = true 
					break
				end
			end
			if is_dup
				return i
			else
				push!(verts, p)
				return length(verts)
			end
		end
	end
	idx1 = add_intersection_point!(verts, 1, i1)
	idx2 = add_intersection_point!(verts, 2, i2)
	idx3 = add_intersection_point!(verts, 3, i3)
	(idx1,idx2,idx3,o_edge)
end

# TODO:
# edge triangles must be constructed
# poly file must be written
# triangulated faces must be oriented properly
# the mesh file is written


#verts, faces = read_OFF("/tmp/buddha-lowres.off")
#verts, faces = read_OFF("/tmp/1.off")
verts, faces = read_OFF(infile)

# rotate such that cutting plane is z=0 plane
q = Matrix3x3(q)
u0 = Vector3(u0)
verts = Vtx{Float64}[q*(v-u0) for v in verts]

# give location of tri relative to z=0 plane.
#  if -1, then under
#  if  0, then on (intersecting)
#  if  1, then above
function tri_location_plane(verts, tri::Face{3,Int64,0})
	num = (verts[tri[1]][3] >= 0.0) +
          (verts[tri[2]][3] >= 0.0) +
          (verts[tri[3]][3] >= 0.0)
    round(Int64,(num/1.5)-1)
end

# add a triangle to the list if it is above the z=0 plane
# and it is also non-empty (distinct endpoints)
function add_tri_above_plane!(faces, verts, tri::Face{3,Int64,0})
	if (tri[1]==tri[2]) || (tri[2]==tri[3]) || (tri[3]==tri[1])
		return
	end
	if tri_location_plane(verts, tri)==1
		push!(faces, tri)
	end
end

# add new vertices;
# and create a new list of faces such that all are above the plane.
n_orig_vert = length(verts)
new_faces = Face{3,Int64,0}[]
edg_v_list = Int64[]
edg_list = Face{2,Int64,0}[]
for tri in faces
	l = tri_location_plane(verts, tri)
	if l==0
		itdx = zeros(Int64,3)
		itdx[1],itdx[2],itdx[3],o_edge = tri_plane_cut!(verts, n_orig_vert, tri[1], tri[2], tri[3])

		add_tri_above_plane!(new_faces, verts, Face(itdx[3],  tri[1], itdx[1]))
		add_tri_above_plane!(new_faces, verts, Face(itdx[1],  tri[2], itdx[2]))
		add_tri_above_plane!(new_faces, verts, Face(itdx[2],  tri[3], itdx[3]))
		add_tri_above_plane!(new_faces, verts, Face(itdx[1], itdx[2], itdx[3]))

		push!(edg_v_list, itdx[o_edge[1]])
		push!(edg_v_list, itdx[o_edge[2]])
		push!(edg_list, Face(itdx[o_edge[1]], itdx[o_edge[2]]))
	elseif l==1
		push!(new_faces, tri)
	end
end

# remove duplicates in edg_v_list
edg_v_list = unique(edg_v_list)

# compute max area (for quality generation)
# TODO
#max_area = 0.0005
max_area = 1.0

# use Triangle to find triangulation of slice
write_poly(verts, edg_v_list, edg_list, "/tmp/out.poly")
run(`triangle -Q -p -a$max_area /tmp/out.poly`)
rm("/tmp/out.poly")

#slice_faces = read_slice_faces("/tmp/out.1.ele", edg_v_list)
#append!(new_faces, slice_faces)

slice_verts = read_node("/tmp/out.1.node")
slice_faces = read_ele( "/tmp/out.1.ele")
n_verts = length(verts)
append!(verts, [Vector3(v[1],v[2],0.0) for v in slice_verts])
flipz = flipz $ flipf
if flipz
  append!(new_faces, Face{3,Int64,0}[Face(f[1]+n_verts,f[2]+n_verts,f[3]+n_verts) for f in slice_faces])
else
	append!(new_faces, Face{3,Int64,0}[Face(f[3]+n_verts,f[2]+n_verts,f[1]+n_verts) for f in slice_faces])
end

rm("/tmp/out.1.ele")
rm("/tmp/out.1.node")
rm("/tmp/out.1.poly")

# remove unused vertices
new_verts = filter(v -> v[3] >= 0.0, verts)
newidx = cumsum([v[3] >= 0.0 for v in verts])
function update_face(tri, newidx)
	Face(newidx[tri[1]], newidx[tri[2]], newidx[tri[3]])
end
new_new_faces = Face{3,Int64,0}[update_face(tri, newidx) for tri in new_faces]

# remove duplicate vertices
# TODO

# write output
qinv = Matrix3x3(inv(q))
new_verts = Vtx{Float64}[(qinv*v)+u0 for v in new_verts]
writeOFF(outfile, new_verts, new_new_faces)

