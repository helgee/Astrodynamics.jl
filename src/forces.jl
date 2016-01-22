function gravity(t::Float64, y::Vector{Float64}, mu::Float64)
    f = zeros(6)
    r = norm(y[1:3])
    f[1:3] = y[4:6]
    f[4:6] = -mu*y[1:3]/r/r/r
    return f
end

function gravity1(t::Float64, y::Vector{Float64}, mu::Float64)
    x, y, z, vx, vy, vz = y
    r = sqrt(x*x+y*y+z*z)
    r3 = r*r*r
    [vx, vy, vz, -mu*x/r3, -mu*y/r3, -mu*z/r3]
end

function gravity!(f::Vector{Float64}, t::Float64, y::Vector{Float64}, mu::Float64)
    r = sqrt(y[1]*y[1]+y[2]*y[2]+y[3]*y[3])
    r3 = r*r*r
    f[1] = y[4]
    f[2] = y[5]
    f[3] = y[6]
    f[4] = -mu*y[1]/r3
    f[5] = -mu*y[2]/r3
    f[6] = -mu*y[3]/r3
end

const mu = 398600.4415 # [km^3/s^2] Earth's gravity
const s0 = [-1814.0, -3708.0, 5153.0, 6.512, -4.229, -0.744]
const tp = 5402.582703094263*100

