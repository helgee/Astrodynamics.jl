function gravity!(f::Vector{Float64}, y::Vector{Float64}, mu::Float64)
    r = sqrt(y[1]*y[1]+y[2]*y[2]+y[3]*y[3])
    r3 = r*r*r
    f[1] += y[4]
    f[2] += y[5]
    f[3] += y[6]
    f[4] += -mu*y[1]/r3
    f[5] += -mu*y[2]/r3
    f[6] += -mu*y[3]/r3
end
