using Compat
using JPLEphemeris

import JPLEphemeris: state, position, velocity
import Base: show

export CelestialBody, Planet
export μ, mu, j2, mean_radius, polar_radius, equatorial_radius
export deviation, max_elevation, max_depression, naif_id
export right_ascension, declination, rotation_angle, rotation_rate
export state, position, velocity
export Sun, SUN

abstract CelestialBody
abstract Planet <: CelestialBody
abstract Satellite <: CelestialBody

immutable Sun <: CelestialBody
    μ::Float64
    mean_radius::Float64
    equatorial_radius::Float64
    polar_radius::Float64
    id::Int
    ra0::Float64
    ra1::Float64
    ra2::Float64
    dec0::Float64
    dec1::Float64
    dec2::Float64
    w0::Float64
    w1::Float64
    w2::Float64
    a::Vector{Float64}
    d::Vector{Float64}
    w::Vector{Float64}
    theta0::Vector{Float64}
    theta1::Vector{Float64}
end

const SUN = Sun(
    1.32712440041e11,
    696000.0,
    696000.0,
    696000.0,
    10,
    deg2rad(286.13),
    0.0,
    0.0,
    deg2rad(63.87),
    0.0,
    0.0,
    deg2rad(84.176),
    deg2rad(14.1844),
    0.0,
    [0.0],
    [0.0],
    [0.0],
    [0.0],
    [0.0],
)
constants(::Type{Sun}) = SUN

const PLANETS = (
    "Mercury",
    "Venus",
    "Earth",
    "Mars",
    "Jupiter",
    "Saturn",
    "Uranus",
    "Neptune",
)

for planet in PLANETS
    typ = Symbol(planet)
    con = Symbol(uppercase(planet))
    @eval begin
        immutable $typ <: Planet
            μ::Float64
            j2::Float64
            mean_radius::Float64
            equatorial_radius::Float64
            polar_radius::Float64
            deviation::Float64
            max_elevation::Float64
            max_depression::Float64
            id::Int
            ra0::Float64
            ra1::Float64
            ra2::Float64
            dec0::Float64
            dec1::Float64
            dec2::Float64
            w0::Float64
            w1::Float64
            w2::Float64
            a::Vector{Float64}
            d::Vector{Float64}
            w::Vector{Float64}
            theta0::Vector{Float64}
            theta1::Vector{Float64}
        end
        constants(::Type{$typ}) = $con
        export $typ, $con
        show(io::IO, ::Type{$typ}) = print(io, $planet)
    end
end

const SATELLITES = (
    "Moon",
)

for satellite in SATELLITES
    typ = Symbol(satellite)
    con = Symbol(uppercase(satellite))
    @eval begin
        immutable $typ <: Satellite
            μ::Float64
            j2::Float64
            mean_radius::Float64
            subplanetary_equatorial::Float64
            along_orbit_equatorial::Float64
            polar_radius::Float64
            deviation::Float64
            max_elevation::Float64
            max_depression::Float64
            id::Int
            ra0::Float64
            ra1::Float64
            ra2::Float64
            dec0::Float64
            dec1::Float64
            dec2::Float64
            w0::Float64
            w1::Float64
            w2::Float64
            a::Vector{Float64}
            d::Vector{Float64}
            w::Vector{Float64}
            theta0::Vector{Float64}
            theta1::Vector{Float64}
        end
        constants(::Type{$typ}) = $con
        export $typ, $con
        show(io::IO, ::Type{$typ}) = print(io, $satellite)
    end
end

for func in (:state, :position, :velocity)
    @eval begin
        $func{C<:CelestialBody}(b::Type{C}, ep::Epoch) = $func(constants(b), juliandate(TDBEpoch(ep)))
        $func{C<:CelestialBody}(b::Type{C}, date::Float64) = $func(constants(b), date)
        $func(b::CelestialBody, ep::Epoch) = $func(b, juliandate(TDBEpoch(ep)))
        function $func(b::CelestialBody, jd::Float64)
            origin = b.id ÷ 100
            if origin == 0
                return $func(DATA.ephemeris, b.id, jd)
            else
                return $func(DATA.ephemeris, origin, jd) + $func(DATA.ephemeris, origin, b.id, jd)
            end
        end
    end
end

theta(t, b) = b.theta0 + b.theta1 * t/SEC_PER_CENTURY

function right_ascension(b::CelestialBody, ep)
    t = seconds(ep)
    mod2pi(b.ra0 + b.ra1*t/SEC_PER_CENTURY
        + b.ra2*t^2/SEC_PER_CENTURY^2
        + sum(b.a .* sin.(theta(t, b))))
end

function declination(b::CelestialBody, ep)
    t = seconds(ep)
    mod2pi(b.dec0 + b.dec1*t/SEC_PER_CENTURY
        + b.dec2*t^2/SEC_PER_CENTURY^2
        + sum(b.d .* cos.(theta(t, b))))
end

function rotation_angle(b::CelestialBody, ep)
    t = seconds(ep)
    mod2pi(b.w0 + b.w1*t/SEC_PER_DAY + b.w2*t^2/SEC_PER_DAY^2
        + sum(b.w .* sin.(theta(t, b))))
end

function right_ascension_rate(b::CelestialBody, ep)
    t = seconds(ep)
    (b.ra1/SEC_PER_CENTURY + 2*b.ra2*t/SEC_PER_CENTURY^2
        + sum(b.a .* b.theta1/SEC_PER_CENTURY .* cos.(theta(t, b))))
end

function declination_rate(b::CelestialBody, ep)
    t = seconds(ep)
    (b.dec1/SEC_PER_CENTURY + 2*b.dec2*t/SEC_PER_CENTURY^2
        + sum(b.d .* b.theta1/SEC_PER_CENTURY .* sin.(theta(t, b))))
end

function rotation_rate(b::CelestialBody, ep)
    t = seconds(ep)
    (b.w1/SEC_PER_DAY + 2*b.w2*t/SEC_PER_DAY^2
        + sum(b.w .* b.theta1/SEC_PER_CENTURY .* cos.(theta(t, b))))
end

μ(p::CelestialBody) = p.μ
mu = μ
mean_radius(p::Planet) = p.mean_radius
polar_radius(p::Planet) = p.polar_radius
equatorial_radius(p::Planet) = p.equatorial_radius
deviation(p::Planet) = p.deviation
max_elevation(p::Planet) = p.max_elevation
max_depression(p::Planet) = p.max_depression
naif_id(p::CelestialBody) = p.id
j2(p::Planet) = p.j2
μ{C<:CelestialBody}(c::Type{C}) = μ(constants(C))
mean_radius{C<:CelestialBody}(c::Type{C}) = mean_radius(constants(C))
j2{C<:CelestialBody}(c::Type{C}) = j2(constants(C))
