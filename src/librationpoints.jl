using Roots
using JPLEphemeris

export libration_dist, gcrf_to_libration_norm, libration_norm_to_gcrf

l1dist(x, μ) = x^3 - μ*(1 - x)^2 / (3 - 2*μ - x*(3 - μ - x))
l2dist(x, μ) = x^3 - μ*(1 + x)^2 / (3 - 2*μ + x*(3 - μ + x))
l3dist(x, μ) = x^3 - (1 - μ)*(1 + x)^2 / (1 + 2*μ + x*(2 + μ + x))

function libration_dist(μ_prime, μ_sec, point)
    μ_lib = 1 / (1 + μ_prime/μ_sec)
    if point == :L1
        initial = (μ_lib / 3 / (1 - μ_lib))^(1/3)
        return fzero((x) -> l1dist(x, μ_lib), initial)
    elseif point == :L2
        initial = (μ_lib / 3 / (1 - μ_lib))^(1/3)
        return fzero((x) -> l2dist(x, μ_lib), initial)
    elseif point == :L3
        initial = 1 - (7*μ_lib/12)
        return fzero((x) -> l3dist(x, μ_lib), initial)
    end
end

function rotation_params(rv)
    M = zeros(3,3)
    rm = norm(rv[1:3])
    M[:,1] = rv[1:3] / rm
    ω = cross(rv[1:3], rv[4:6])
    M[:,3] = ω / norm(ω)
    M[:,2] = cross(M[:,3], M[:,1])

    Ω = norm(ω) / rm^2
    return M, rm, Ω
end

function gcrf_to_libration_norm(rv, epoch, primary, secondary, point)
    γ = libration_dist(μ(primary), μ(secondary), point)
    rv_sec = state(DATA.ephemeris, naif_id(primary)÷100, naif_id(secondary), epoch.jd, epoch.jd1)
    rv_lib = rv - rv_sec*(1 + γ)

    M, rm, Ω = rotation_params(rv_sec)
    rv_lib[1:3] = M'*rv_lib[1:3]
    rv_lib[4:6] = M'*rv_lib[4:6] - [-Ω*rv_lib[2], Ω*rv_lib[1], 0.0]
    rv_lib[1:3] /= rm
    rv_lib[4:6] /= rm*Ω
    return rv_lib
end

function libration_norm_to_gcrf(rv_lib, epoch, primary, secondary, point)
    γ = libration_dist(μ(primary), μ(secondary), point)
    rv_sec = state(DATA.ephemeris, naif_id(primary)÷100, naif_id(secondary), epoch.jd, epoch.jd1)

    M, rm, Ω = rotation_params(rv_sec)
    rv_eci = rv_lib
    rv_eci[4:6] += [-rv_lib[2], rv_lib[1], 0.0]
    rv_eci[1:3] = M*rv_eci[1:3]
    rv_eci[4:6] = M*rv_eci[4:6]
    rv_eci[1:3] *= rm
    rv_eci[4:6] *= Ω*rm
    rv_eci = rv_eci + rv_sec*(1 + γ)
    return rv_eci
end
