export State

using ERFA

import Base: convert

export Frame, IAU
export ECI, ECEF, SEZ
export GCRF, CIRF, TIRF, ITRF

export rotation_matrix

abstract Frame

abstract GCRF <: Frame
abstract CIRF <: GCRF
abstract TIRF <: CIRF
abstract ITRF <: TIRF

abstract ECI <: GCRF
abstract ECEF <: ECI
abstract SEZ <: ECI

abstract IAU{C<:CelestialBody} <: GCRF

abstract AbstractState

immutable State{F<:Frame, T<:Timescale, C<:CelestialBody} <: AbstractState
    frame::Type{F}
    epoch::Epoch{T}
    rv::Vector{Float64}
    body::C
end

const FRAMES = (
    :GCRF,
    :CIRF,
    :TIRF,
    :ITRF,
    :ECI,
    :ECEF
)

function rotation_matrix(p::Planet, ep::Epoch)
    α = right_ascension(p, ep)
    δα = right_ascension_rate(p, ep)
    δ = declination(p, ep)
    δδ = declination_rate(p, ep)
    ω = rotation_angle(p, ep)
    δω = rotation_rate(p, ep)
    ϕ = α + π/2
    χ = π/2 - δ

    M = zeros(6, 6)
    m = rotation_matrix(313, ϕ, χ, ω)
    δm = rate_matrix(313, ϕ, δα, χ, -δδ, ω, δω)
    M[1:3,1:3] = m
    M[4:6,4:6] = m
    M[4:6,1:3] = δm
    return M
end

function convert{F<:Frame, T<:Timescale, C<:CelestialBody}(::Type{State{IAU{C}}}, s::State{F,T,C})
    println("läuft")
end

rotation_matrix{T<:Planet}(p::Type{T}, ep::Epoch) = rotation_matrix(constants(p), ep)

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
