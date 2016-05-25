
using PyPlot
using ImmutableArrays
using Images

push!(LOAD_PATH,".")
include("CurveFraming.jl")
include("PiecewiseLinear.jl")
using CurveFraming
using PiecewiseLinear

# load all paths and compute average
	# vert = Vector3{Float64}[Vector3(randn(3)) for i=1:40]
	# nois = Vector3{Float64}[Vector3(0.1*randn(3)) for i=1:40]
	# v = cumsum(vert).+nois
	# v = map(x -> x/norm(x), v)

	# startp = cumsum(v)



# smooth a curve
function filter_curve_gaussian{T}(vert::Array{Vector3{T}},sig)
	N = length(vert)
	cs = reshape(reinterpret(T,vert),3,N)
	cs = Images.imfilter_gaussian(cs,[0.0,sig])
	reinterpret(Vector3{T},cs,(N,))
end

# downsample a curve (and smooth it first)
function downsample_curve(vert,sig,skip)
	v = filter_curve_gaussian(vert,sig)
	v = unique(v)
	v[1:skip:end]
end

# downsample a curve based on arc length.
# sig: the amount to smooth it first.
# charlen: characteristic length of segments
function downsample_curve_arclength(vert,sig,charlen)
	v = filter_curve_gaussian(vert,sig)
	curv = PiecewiseLinearCurve3D(v)
	l = curv_length(curv)
	Vector3[evaluate(curv, t) for t=0:charlen:l]
end

# take a curve, and a frame, and produce
# a set of control points suitable for tps.
# extrude: extrude amount for each vertex.
function curve_to_tps_ctrlpts{T}(vert::Array{Vector3{T}},frm::Vector{Matrix3x3{T}},extrude)
	tps_ctrlpts = Vector3{T}[]
	for i = 1:length(frm)
		# c1 is tangent; c2 and c3 are normal/binormal
		push!(tps_ctrlpts, vert[i])
		push!(tps_ctrlpts, vert[i] - extrude*frm[i].c2)
		push!(tps_ctrlpts, vert[i] + extrude*frm[i].c2)
		push!(tps_ctrlpts, vert[i] - extrude*frm[i].c3)
		push!(tps_ctrlpts, vert[i] + extrude*frm[i].c3)
	end
	push!(tps_ctrlpts, vert[end])
	# reshape, transpose, and return
	return reshape(reinterpret(T,tps_ctrlpts),3,length(tps_ctrlpts))'
end

function curve_to_tps_ctrlpts{T}(vert::Vector{Vector3{T}},nrml::Vector3{T},extrude)
	frm = frame_curve_parallel(vert,nrml)
	return curve_to_tps_ctrlpts(vert,frm,extrude)
end


# take a list of curves,
# calculate their average,
# and generate a set of TPS deformations
# that deform each to the average.
# nrml: initial normal
# sig: smoothing parameter
# charlen: characteristic length between control points
# min_n_ctrlpts: reject any curves that have less than this
#   number of control points.
function congeal_curves{T}(v::Array{Vector{Vector3{T}}},nrml,min_n_ctrlpts,sig,charlen,extrude)
	n_curves = length(v)
	
	# downsample all curves
	downsampled_v = Vector{Vector3{T}}[downsample_curve_arclength(c,sig,charlen) for c in v]
	
	# reject
	filter!(x -> length(x)>min_n_ctrlpts, downsampled_v)
	
	# obtain *actual* minimum control points
	min_n_ctrlpts = minimum(map(length, downsampled_v))
	
	# now make all control point vectors uniform
	downsampled_v = map(x->x[1:min_n_ctrlpts],downsampled_v)
	
	# take average!
	mean_v = mean(downsampled_v)

	# generate TPS deformations
	ctrlpts_v = Matrix{T}[curve_to_tps_ctrlpts(x,nrml,extrude) for x in downsampled_v]
	ctrlpts_mean = curve_to_tps_ctrlpts(mean_v, nrml, extrude)

	return (ctrlpts_v, ctrlpts_mean)
end
