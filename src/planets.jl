# [1] Luzum, Brian, et al. "The IAU 2009 system of astronomical constants: the report of the IAU working group on numerical standards for Fundamental Astronomy." Celestial Mechanics and Dynamical Astronomy 110.4 (2011): 293-304.
# [2] Archinal, Brent Allen, et al. "Report of the IAU working group on cartographic coordinates and rotational elements: 2009." Celestial Mechanics and Dynamical Astronomy 109.2 (2011): 101-135.

export EARTH
export μ, mu, j2, mean_radius, polar_radius, equatorial_radius
export deviation, max_elevation, max_depression, id

abstract Body
abstract Planet <: Body

planets = (
    :Mercury,
    :Venus,
    :Earth,
    :Mars,
    :Jupiter,
    :Saturn,
    :Uranus,
    :Neptune
)

for planet in planets
    eval(quote
        immutable $planet <: Planet
            μ::Float64
            j2::Float64
            mean_radius::Float64
            polar_radius::Float64
            equatorial_radius::Float64
            deviation::Float64
            max_elevation::Float64
            max_depression::Float64
            id::Int
        end
    end)
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

function rightascension(p::Body, ep::Epoch)
    centuries = (juliandate(ep) - J2000)/JULIAN_CENTURY
    rightascension(p, centuries)
end

function declination(p::Body, ep::Epoch)
    centuries = (juliandate(ep) - J2000)/JULIAN_CENTURY
    declination(p, centuries)
end

function rotation_angle(p::Body, ep::Epoch)
    days = juliandate(ep) - J2000
    rotation_angle(p, days)
end

function rotation_rate(p::Body, ep::Epoch)
    days = juliandate(ep) - J2000
    rotation_rate(p, days)
end

const EARTH = Earth(
    3.986004418e5, # [1]
    1.0826359e-3, # [1]
    6371.0084, # [2]
    6378.1366, # [2]
    6356.7519, # [2]
    3.57, # [2]
    8.85, # [2]
    11.52, # [2]
    399,
)

# [2]
rightascension(p::Earth, T::Float64) = mod2pi(deg2rad(0.0-0.641T))
declination(p::Earth, T::Float64) = mod2pi(deg2rad(90.0-0.557T))
rotation_angle(p::Earth, d::Float64) = mod2pi(deg2rad(190.147 + 360.9856235d))
rotation_rate(p::Earth, d::Float64) = deg2rad(360.9856235)
