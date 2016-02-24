using HDF5
include("OFF.jl")

r = 60.0
slices = 1:300

orientation = :native  # :coronal

# TODO: compute this from SC, etc.
# The exact z-values aren't important;
# just that they match up with what was given to vmtkimagereader.py
spacing = [0.1,0.5125628140703586,0.1]

# TODO: in the mesher, the coordinates need to be
# permuted (x,y,z) -> (x,z,y)
# so that ALL meshes exist in the same coordinate system.

# load command-line arguments
if length(ARGS) < 3
	println("Usage: bend-mesh.jl <slicexforms.hdf5> <input file.off> <output file.off>")
	exit()
end
slicexform_filename = ARGS[1]
ifile = ARGS[2]
ofile = ARGS[3]

type SliceTransform{T}
	transl_1::Vector{T}
	invrot::Matrix{T}
	transl_2::Vector{T}
end
function read_transform(d)
	t1 = d["transl_1"]
	ir = d["rot_1"]
	t2 = d["transl_2"]
	SliceTransform(t1,inv(ir),t2)
end
function interp_transform(x,y,fpart)
	t1 = (1.0 - fpart)*x.transl_1 + fpart*y.transl_1
	ir = (1.0 - fpart)*x.invrot   + fpart*y.invrot
	t2 = (1.0 - fpart)*x.transl_2 + fpart*y.transl_2
	SliceTransform(t1,ir,t2)
end
function deapply_transform{T}(vert::Vector3{T},x)
	v = convert(Array, vert)
	v = v .- [0.0,v[2],0.0]  # bring to y=0 plane
	v2 = (x.invrot*(v-x.transl_2))-x.transl_1
	Vector3{T}(v2)
end


# -----------------------------------------------
println("loading slice transforms")
fid = h5open(slicexform_filename,"r")
slc_ids = [@sprintf("%04d",i) for i in slices];
xforms = SliceTransform{Float64}[read_transform(read(fid[id])) for id in slc_ids]
close(fid)

# load input
println("Reading input mesh.")
verts, faces = read_OFF(ifile)

if orientation == :native
	verts = Vector3{Float64}[Vector3(v[1],v[3],80-v[2]) for v in verts]
	orientation = :coronal
end

# reverses the forward transformation implied by the slicexforms file
function xform_vert(vert,i)
	v = convert(Array,vert)
	#v = v .- [0.0,v[2],300.0]  # bring to y=0 plane
	v = v .- [0.0,v[2],0.0]  # bring to y=0 plane
	v2 = (invrot[i]*(v-transl_2[i]))-transl_1[i]
	Vector3(v2)
end

# bending function;
# all this does is just interpolate between the
# rotations given by the adjacent slices.
function bend_vert(vert)
	# find slices that the pixel is between
	fpart,ipart = modf(vert[2]/spacing[2])
	i2 = round(Integer,ipart)+1
	i1 = i2-1

	# edge cases; repeat first or last
	if i2>length(slices)
		i2=i1
	end
	if i2==1
		i1=1
		i2=1
	end

	x = interp_transform(xforms[i1], xforms[i2], fpart)
	deapply_transform(vert, x)
end

println("Transforming.")
newverts = Vector3{Float64}[bend_vert(v) for v in verts]

println("Writing output mesh.")
writeOFF(ofile, newverts, faces)