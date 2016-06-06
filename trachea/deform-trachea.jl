using JLD, HDF5
using ThinPlateSplines
include("../OFF.jl")
include("vec3-util.jl")

# Check input arguments
if length(ARGS) < 3
	println("Usage: deform-trachea.jl <inputmesh.off> <inputdef.jld> <outputmesh.off>")
	exit()
end

inmesh  = ARGS[1]
indef   = ARGS[2]
outmesh = ARGS[3]

# Load inputs
verts, faces = read_OFF(inmesh)
tps = load(indef, "tps")

# deform vertices
va = convert(Matrix{Float64}, verts)'
va_def = tps_deform(va,tps)
verts = convert(Vector{Vector3{Float64}}, va_def')

# save output
writeOFF(outmesh, verts, faces)