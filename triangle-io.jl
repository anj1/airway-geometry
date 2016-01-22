# I/O for interfacing with Jonathan Shewchuk's Triangle program

using GeometryTypes
using ImmutableArrays

# write edges as PSLG file
# verts is a list of vertex coordinates
#  (typically for the whole model)
# edg_v_list is a list of vertex indices that are on the edge
# edges is a list of tuples (idx1,idx2)
# outfile is the name of the output file
function write_poly(verts, edg_v_list, edges, outfile)
	fid = open(outfile, "w")

	# assign each vertex a new id
	println(fid, string(length(edg_v_list)) * " 2 0 0")
	new_assgn = zeros(Int64, length(verts))
	for i=1:length(edg_v_list)
		ei = edg_v_list[i]
		new_assgn[ei]=i
		x = verts[ei].e1
		y = verts[ei].e2
		println(fid, "$i $x $y")
	end

	println(fid, string(length(edges)) * " 0")
	#new_fc = zeros(Int64,length(edges),3)
	for i=1:length(edges)
		#new_fc[i,1]=i
		#new_fc[i,2]=new_assgn[edges[1]]
		#new_fc[i,3]=new_assgn[edges[2]]
		fc1=new_assgn[edges[i][1]]
		fc2=new_assgn[edges[i][2]]
		println(fid, "$i $fc1 $fc2")
	end

	println(fid, "0")

	close(fid)

	#return new_assgn
end

# load .node file and read vertices
function read_node(infile)
	fid = open(infile, "r")

	local verts
	j=0
	while(true)
		l = readline(fid)
		eof(fid)    && break
		isempty(l)  && continue  # skip empty lines
		l[1] == '#' && continue  # skip comments

		if j==0 # is header?
			# parse
			n_ele, n_dim, n_attr, n_bound = map(parse, split(l,' ',keep=false))
			assert(n_dim==2)
			verts = Array(Vector2{Float64},n_ele)
		else
			# otherwise, add element
			l_splt = split(l,' ',keep=false)
			n = [parse(Float64,s) for s in l_splt[2:end]]
			verts[j] = Vector2(n[1],n[2])
		end
		j+=1
	end

	close(fid)
	return verts
end

# load .ele file and read elements
function read_ele(infile)
	fid = open(infile, "r")

	local faces
	j=0
	while(true)
		l = readline(fid)
		eof(fid)    && break
		isempty(l)  && continue  # skip empty lines
		l[1] == '#' && continue  # skip comments

		if j==0 # is header?
			# parse
			n_ele, n_dim, n_attr = map(parse, split(l,' ',keep=false))
			assert(n_dim==3)
			faces = Array(Face{3,Int64,0},n_ele)
		else
			# otherwise, add element
			#idx,i1,i2,i3 = map(parse, split(l,' ',keep=false))
			n = [parse(Int,s) for s in split(l,' ',keep=false)]
			faces[j] = Face(n[2:4]...)
		end
		j+=1
	end

	close(fid)
	return faces
end

function read_slice_faces(infile, edg_v_list)
	faces = read_ele(infile)
	for i=1:length(faces)
		fi = faces[i]
		faces[i] = Face(edg_v_list[fi[3]],
		                edg_v_list[fi[2]],
		                edg_v_list[fi[1]])
	end
	faces
end
