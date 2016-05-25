
using PyPlot
using ImmutableArrays

push!(LOAD_PATH,".")
include("CurveFraming.jl")
using CurveFraming

# load all paths and compute average


# startp: array of 3d start points
# v: array of 3d vector lengths
function plot_vecarrows(ax,startp,v,fmt)
	cs = reshape(reinterpret(Float64,startp),3,length(startp))
	cv = reshape(reinterpret(Float64,v     ),3,length(v))
	x = vec(cs[1,:])
	y = vec(cs[2,:])
	z = vec(cs[3,:])
	u = vec(cv[1,:])
	v = vec(cv[2,:])
	w = vec(cv[3,:])
	ax["quiver"](x,y,z,u,v,w,color=fmt)
end

function plot_curve(ax,startp)
	cs = reshape(reinterpret(Float64,startp),3,length(startp))
	x = vec(cs[1,:])
	y = vec(cs[2,:])
	z = vec(cs[3,:])
	ax["plot3D"](x,y,z,"r-")
end


function test_parallel_transport()
	fig = figure()

	ax = fig["add_subplot"](111,projection="3d")

	vert = Vector3{Float64}[Vector3(randn(3)) for i=1:40]
	nois = Vector3{Float64}[Vector3(0.1*randn(3)) for i=1:40]
	v = cumsum(vert).+nois
	v = map(x -> x/norm(x), v)

	startp = cumsum(v)
	frm = frame_curve_parallel(startp)

	#plot_curve(ax,startp)
	plot_vecarrows(ax,startp[1:end-1],Vector3{Float64}[f.c1 for f in frm],"r")
	plot_vecarrows(ax,startp[1:end-1],Vector3{Float64}[f.c2 for f in frm],"g")
	plot_vecarrows(ax,startp[1:end-1],Vector3{Float64}[f.c3 for f in frm],"b")
end

# first:
# we smooth out the vertex coordinates and down-sample.

# then:
# we place a coordinate frame on every vertex.
# the coordinate frame on each vertex likes to 
# 'smooth out' between the coordinate frames of its
# neighbors. But it also likes to be of unit length.
# and the tangent component likes to be, well, tangent
# to the line from that vertex to the next.

# the initialization is simply the osculating reference frame.
