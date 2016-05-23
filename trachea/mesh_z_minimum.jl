# Find the z-axis minimum of a mesh.
include("OFF.jl")
verts,faces=read_OFF(ARGS[end])
println(minimum([v[3] for v in verts]))