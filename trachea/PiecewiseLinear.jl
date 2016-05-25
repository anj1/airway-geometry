# Representing _continuous_ piecewise curves
# in a way such that v (velocity) across the curves
# is always constant, and we can sample from any
# distance along the curve.

module PiecewiseLinear

export PiecewiseLinearCurve3D, curv_length, evaluate

using ImmutableArrays
using Dierckx

# return the cumulative distance over a path
function arc_distance(vert)
	# distance from each point to the next
	d_vert = vert[2:end]-vert[1:end-1]
	# cumulate distance (add some small epsilon)
	s = cumsum(map(norm, d_vert))
	# add 0 to the beginning
	vcat([0.0],s)
end

# A type for piecewise-linear continuous curves,
# based on Dierckx interpolation
type PiecewiseLinearCurve3D
	t              # position along curve
	x::Spline1D    # coordinates
	y::Spline1D
	z::Spline1D
end

curv_length(curv::PiecewiseLinearCurve3D) = curv.t[end]

# create a piecewise-linear continuous curve from a set of vertices.
function PiecewiseLinearCurve3D{T}(vert::Array{Vector3{T}})
	t = arc_distance(vert)
	cs = reshape(reinterpret(T,vert),3,length(vert))
	x = Spline1D(t, vec(cs[1,:]), k=1) # k=1 makes it linear
	y = Spline1D(t, vec(cs[2,:]), k=1)
	z = Spline1D(t, vec(cs[3,:]), k=1)
	PiecewiseLinearCurve3D(t,x,y,z)
end

# evaluate the curve at some point t
function Dierckx.evaluate(curv::PiecewiseLinearCurve3D, t)
	x = evaluate(curv.x, t)
	y = evaluate(curv.y, t)
	z = evaluate(curv.z, t)
	Vector3(x,y,z)
end

end