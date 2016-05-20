export State

abstract AbstractState

immutable State{T<:Frame, S<:Timescale} <: AbstractState
    frame::Type{T}
    epoch::Epoch{S}
    rv::Vector{Float64}
    body::Symbol
end

Base.eltype{T,S}(::Type{State{T,S}}) = T

body(s::State) = s.body
rv(s::State) = s.rv
epoch(s::State) = s.epoch
reference_frame(s::State) = s.frame

elements(s::State) = elements(rv(s), μ(body(s)))

type StateSpace <: AbstractState
end

for frame in FRAMES
    sym = symbol(frame, "State")
    @eval begin
        typealias $(sym) State{$frame}
        export $sym
    end
end
# Constructor for typealiases
Base.call{T<:Frame}(::Type{State{T}}, args...; kwargs...) = State(T, args...; kwargs...)
