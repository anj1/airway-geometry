module CurveFraming

# Curve framing refers to the process of
# attaching a coordinate frame to every vertex
# of a piecewise curve.

# The coordinate frame has three components: 
# The tangent, normal, and binormal.
# The tangent is always, well, tangent to the curve,
# And all 3 components are orthogonal to each other.
# There is ambiguity when framing a 3d curve since
# there are an infinity of possible choices for the
# normal and binormal.
# The two common methods of resolving this ambiguity
# are Frenet frames and Parallel transport frames.
# please see:
# 'Parallel Transport Approach to Curve Framing'
# by J. Hanson and H. Ma (1995)
# https://www.cs.indiana.edu/ftp/techreports/TR425.pdf

export frame_curve_frenet, frame_curve_parallel

using ImmutableArrays

normalize(p::Vector3) = p/norm(p)

function tangents{T}(vert::Vector{Vector3{T}})
	N = length(vert)
	Vector3{T}[normalize(vert[i+1]-vert[i]) for i=1:(N-1)]
end

function vecs_to_mats{T}(t::Vector{Vector3{T}},n::Vector{Vector3{T}},b::Vector{Vector3{T}})
	Matrix3x3{T}[Matrix3x3(t[i],n[i],b[i]) for i=1:length(t)]
end

# given a set of vertices, produce the 'canonical'
# reference frame.
function frame_curve_frenet(vert)
	# compute tangents along curve
	tangnt = tangents(vert)
	
	# first normal and binormal
	n,b = cols(nullspace(tangnt[1]))

	# the rest of the normals
	normal = Vector3[normalize(tangnt[i]×tangnt[i+1]) for i=1:(N-2)]
	unshift!(normal, Vector3(n))

	# the rest of the binormals
	binorm = Vector3[tangnt[i]×normal[i] for i=1:(N-1)]

	# wrap it up as a set of frames
	vecs_to_mats(tangnt, normal, binorm)
end

# give a rotation of θ degrees about axis a
function rot_matrix(a,θ)
	c = cos(θ)
	s = sin(θ)
	n1,n2,n3 = a[1],a[2],a[3]
	Matrix3x3([c+n1*n1*(1-c)	n1*n2*(1-c)-s*n3	n3*n1*(1-c)+s*n2
	          n1*n2*(1-c)+s*n3	c+(n2*n2)*(1-c)		n3*n2*(1-c)-s*n1
	          n1*n3*(1-c)-s*n2	n2*n3*(1-c)+s*n1	c+(n3*n3)*(1-c)])
end

# tangnt: a list of tangent vectors; normalized
# n: an initial normal vector to be transported.
# output: A list of transported normal vectors
function parallel_transport_normal{T}(tangnt::Vector{Vector3{T}},n::Vector3{T})
	tol = 1e-6
	normal = Vector3{T}[n]
	for i = 1 : length(tangnt)-1
		binorm = tangnt[i] × tangnt[i+1]
		if norm(binorm) > tol
			bn = normalize(binorm)
			θ = acos(dot(tangnt[i], tangnt[i+1]))
			n = rot_matrix(bn,θ)*n
		end
		push!(normal, n)
	end
	return normal
end

cols{T}(m::Array{T,2}) = Array{T,1}[m[:,i] for i=1:size(m,2)]

import Base.nullspace
nullspace(v::Vector3) = nullspace(convert(Array, v)')

# frame curve according to parallel transport;
# transporting the specified normal along the curve. 
function frame_curve_parallel{T}(vert::Vector{Vector3{T}},n::Vector3{T})
	# compute tangents along curve
	tangnt = tangents(vert)

	# the rest of the normals
	normal = parallel_transport_normal(tangnt, n)

	#@show norm(normal[1]), norm(tangnt[1]), dot(normal[2],tangnt[1])
	#@show norm(normal[2]), norm(tangnt[2]), dot(normal[1],tangnt[2])

	# ... and the rest of the binormals
	binorm = Vector3{T}[normal[i]×tangnt[i] for i=1:length(normal)]

	# wrap it up as a set of frames
	vecs_to_mats(tangnt, normal, binorm)
end

# frame curve according to parallel transport;
# choosing some arbitrary normal for the first frame,
# and transporting this along the curve. 
function frame_curve_parallel(vert)
	# first tangent, normal, and binormal
	t = normalize(vert[2]-vert[1])
	n,b = cols(nullspace(t))
	
	frame_curve_parallel(vert,Vector3(n))
end

end