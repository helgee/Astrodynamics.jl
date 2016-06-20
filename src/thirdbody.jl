function thirdbody!(f::Vector{Float64}, t::Float64, y::Vector{Float64}, params, propagator)
    date = juliandate(params.s0.epoch) + t/SEC_PER_DAY
    rc = position(propagator.center, date)
    for body in propagator.bodies
        mu3 = μ(body)
        r3 = position(body, date) - rc
        rs = y[1:3] - r3
        rsm = sqrt(rs[1]*rs[1]+rs[2]*rs[2]+rs[3]*rs[3])
        rsm3 = rsm*rsm*rsm
        r3m = sqrt(r3[1]*r3[1]+r3[2]*r3[2]+r3[3]*r3[3])
        r3m3 = r3m*r3m*r3m
        f[4] += mu3 / rsm3 * rs[1] - mu3/r3m3 * r3[1]
        f[5] += mu3 / rsm3 * rs[2] - mu3/r3m3 * r3[2]
        f[6] += mu3 / rsm3 * rs[3] - mu3/r3m3 * r3[3]
    end
end
