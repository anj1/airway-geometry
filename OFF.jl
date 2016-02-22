using Meshes
import Meshes.Face
using ImmutableArrays

function read_OFF(filename)
	f = open(filename,"r")

	# make sure it's an OFF file
	assert(readline(f) == "OFF\n")

	# read number of vertices, faces, and edges
	nvert, nface, nedge=vec(eval(parse("[" * readline(f) * "]")))

	# read rest of file.
	lines = readlines(f);

	# separate out vertices
	vb = convert(Array{UInt8},join(lines[1:nvert]))
	verts = reinterpret(Vector3{Float64},readdlm(vb,Float64)',(nvert,))

	# separate out faces
	fb = convert(Array{UInt8},join(lines[nvert+1:nvert+nface]))
	faces0 = readdlm(fb,Int64)
	faces = reinterpret(Face{3,Int,0},faces0[:,2:end]'+1,(nface,))

	verts, faces
end

function writeOFF(filename, verts, faces)
	f = open(filename,"w")

	# magic identifier
	write(f,"OFF\n")

	# write number of vertices, faces, and edges
	write(f, string(length(verts)) * " " * string(length(faces)) * " 0\n")

	# write out vertices
	va = reinterpret(Float64,verts,(3,length(verts)))'
	writedlm(f, va, " ")

	# write out faces
	fa = reinterpret(Int64,faces,(3,length(faces)))'-1
	fn = repmat([3],length(faces))
	writedlm(f, cat(2, fn, fa), " ")

	close(f)
end
