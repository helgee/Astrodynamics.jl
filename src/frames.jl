using ERFA

export Frame, IAURotating, IAUInertial
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

abstract IAURotating{T<:Planet} <: GCRF
abstract IAUInertial{T<:Planet} <: GCRF

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

function rotation{T<:Planet}(from::Type{GCRF}, to::Type{IAURotating{T}}, ep::Epoch)
    rotation(to, from, ep)'
end
