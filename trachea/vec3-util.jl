# A pair of utility functions for converting between
# points represented as Vector3's and as matrices.

function Base.convert{T}(::Type{Matrix{T}},a::Vector{Vector3{T}})
	reinterpret(T,a,(3,length(a)))
end

function Base.convert{T}(::Type{Vector{Vector3{T}}},a::Matrix{T})
	reinterpret(Vector3{T},a,(size(a,2),))
end