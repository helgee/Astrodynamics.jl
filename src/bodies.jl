# [1] Luzum, Brian, et al. "The IAU 2009 system of astronomical constants: the report of the IAU working group on numerical standards for Fundamental Astronomy." Celestial Mechanics and Dynamical Astronomy 110.4 (2011): 293-304.
# [2] Archinal, Brent Allen, et al. "Report of the IAU working group on cartographic coordinates and rotational elements: 2009." Celestial Mechanics and Dynamical Astronomy 109.2 (2011): 101-135.

export EARTH
export μ, mu, j2, mean_radius, polar_radius, equatorial_radius
export deviation, max_elevation, max_depression, id
export right_ascension, declination, rotation_angle, rotation_rate

abstract CelestialBody

immutable Planet <: CelestialBody
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

theta(t, theta0, theta1) = theta0 + theta1 * t/SEC_PER_CENTURY

function right_ascension(b::CelestialBody, ep)
    t = seconds(ep)
    mod2pi(b.ra0 + b.ra1*t/SEC_PER_CENTURY
        + b.ra2*t^2/SEC_PER_CENTURY^2
        + sum(b.a .* sin(theta(t, b.theta0, b.theta1))))
end

function right_ascension_rate(b::CelestialBody, ep)
    t = seconds(ep)
    (b.ra1/SEC_PER_CENTURY + 2*b.ra2*t/SEC_PER_CENTURY^2
        + sum(b.a .* b.theta1./SEC_PER_CENTURY .* cos(theta(t, b.theta0, b.theta1))))
end

function declination(b::CelestialBody, ep)
    t = seconds(ep)
    mod2pi(b.dec0 + b.dec1*t/SEC_PER_CENTURY
        + b.dec2*t^2/SEC_PER_CENTURY^2
        + sum(b.d .* cos(theta(t, b.theta0, b.theta1))))
end

function declination_rate(b::CelestialBody, ep)
    t = seconds(ep)
    b.dec1/SEC_PER_CENTURY + 2*b.dec2*t/SEC_PER_CENTURY^2 + sum(
        b.d .* b.theta1./SEC_PER_CENTURY .* sin(theta(t, b.theta0, b.theta1)))
end

function rotation_angle(b::CelestialBody, ep)
    t = seconds(ep)
    mod2pi(b.w0 + b.w1*t/SEC_PER_DAY + b.w2*t^2/SEC_PER_DAY^2 + sum(b.w .* sin(theta(t, b.theta0, b.theta1))))
end

function rotation_rate(b::CelestialBody, ep)
    t = seconds(ep)
    b.w1/SEC_PER_DAY + 2*b.w2*t/SEC_PER_DAY^2 + sum(
        b.w .* b.theta1./SEC_PER_CENTURY .* cos(theta(t, b.theta0, b.theta1)))
end

μ(p::Planet) = p.μ
mu = μ
mean_radius(p::Planet) = p.mean_radius
polar_radius(p::Planet) = p.polar_radius
equatorial_radius(p::Planet) = p.equatorial_radius
deviation(p::Planet) = p.deviation
max_elevation(p::Planet) = p.max_elevation
max_depression(p::Planet) = p.max_depression
id(p::Planet) = p.id
