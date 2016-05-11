using ERFA

export Frame, IAURotating, IAUInertial
export ECI, ECEF, SEZ
export GCRF, CIRF, TIRF, ITRF

export rotation

abstract Frame

abstract GCRF <: Frame
abstract CIRF <: GCRF
abstract TIRF <: CIRF
abstract ITRF <: TIRF

abstract ECI <: GCRF
abstract ECEF <: ECI
abstract SEZ <: ECI

abstract Kepler <: GCRF

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

function rotation{T<:Planet}(from::Type{IAURotating{T}}, to::Type{GCRF}, ep::Epoch)
    alpha = rightascension(T, ep)
    delta = declination(T, ep)
    omega = rotation_angle(T, ep)
    euler2dcm(313, omega, pi/2-delta, pi/2+alpha)
end

function rotation{T<:Planet}(from::Type{GCRF}, to::Type{IAURotating{T}}, ep::Epoch)
    rotation(to, from, ep)'
end
