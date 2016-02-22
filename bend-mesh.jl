using HDF5
include("OFF.jl")

r = 60.0
slices = 1:300

# TODO: compute this from SC, etc.
# The exact z-values aren't important;
# just that they match up with what was given to vmtkimagereader.py
spacing = [0.1,0.1,0.5125628140703586]

# TODO: in the mesher, the coordinates need to be
# permuted (x,y,z) -> (x,z,y)
# so that ALL meshes exist in the same coordinate system.

# load command-line arguments
if length(ARGS) < 3
	println("Usage: bend-mesh.jl <slicecoords.csv> <input file.off> <output file.off>")
	exit()
end
slicecoord_filename = ARGS[1]
ifile = ARGS[2]
ofile = ARGS[3]

# -----------------------------------------------
println("loading slice transforms")
fid = h5open("data/slicexforms.hdf5","r")
slc_ids = [@sprintf("%04d",i) for i in slices];
transl_1 = Array{Float64,1}[read(fid[id])["transl_1"]   for id in slc_ids];
invrot_1 = Array{Float64,2}[inv(read(fid[id])["rot_1"]) for id in slc_ids];
transl_2 = Array{Float64,1}[read(fid[id])["transl_2"]   for id in slc_ids];

# load input
println("Reading input mesh.")
verts, faces = read_OFF(ifile)

# reverses the forward transformation implied by the slicexforms file
function xform_vert(vert,i)
	v = convert(Array,vert)
	v2 = (invrot*(v-transl_2))-transl_1
	Vector3(v2)
end

# bending function;
# all this does is just interpolate between the
# rotations given by the adjacent slices.
function bend_vert(vert)
	# find slices that the pixel is between
	fpart,ipart = modf(vert[3]/spacing[3])
	i2 = round(Integer,ipart)
	i1 = i2-1

	# edge cases; repeat first or last
	if i2>length(pln_y)
		i2=i1
	end
	if i2==1
		i1=1
		i2=1
	end

	vert1 = xform_vert(vert, i1)
	vert2 = xform_vert(vert, i1)
	(1-fpart)*vert1 + fpart*vert2
end

newverts = [bend_vert(v) for v in verts]
writeOFF(ofile, newverts, faces)