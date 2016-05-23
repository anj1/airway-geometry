# align mesh to specified landmarks from file

using ImmutableArrays
using Meshes

include("OFF.jl")

if length(ARGS) < 3
	println("Usage: align_to_landmarks.jl <mesh.off> <output.off> <landmark file.csv>")
	exit()
end

sc = 10   # scale

nost_width = 9 # nostril thickness for morphology operations
remove_air = false
output_skel = false
enclose = true  # enclose mesh

mshfile = ARGS[end-2]
outfile = ARGS[end-1]
lm_file = ARGS[end]

# read data
# ---------

# read landmarks
lm = readcsv(lm_file)'

# read test and reference clouds
verts,faces = read_OFF(mshfile)

# align mesh
# find rotation matrix to align the line between the landmarks
# to the y axis.
function find_rot_matrix(lm)
	lm2 = lm[:,2]-lm[:,1]  # bring AMS to origin
	r = norm(lm2)
	a= lm2/r
	b = [0.0,-1.0,0.0]
	v = a×b
	s = norm(v)
	c = a⋅b
	vx = [0 -v[3] v[2]; v[3] 0 -v[1]; -v[2] v[1] 0]
	I + vx + (1-c)*vx*vx/(s*s)
end
R = convert(Matrix3x3{Float64}, find_rot_matrix(lm))
org = Vector3(lm[:,1])  # origin
newverts = Vector3{Float64}[(R*(v - org)) for v in verts]

writeOFF(outfile,newverts,faces)