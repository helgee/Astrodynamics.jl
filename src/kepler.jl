function meantoecc(M::Float64, ecc::Float64)
    kepler(E) = E - ecc*sin(E) - M
    kepler_der(E) = 1 - ecc*cos(E)
    return newton(M, kepler, kepler_der)
end

function ecctomean(E::Float64, ecc::Float64)
    return E - ecc*sin(E)
end

function ecctotrue(E::Float64, ecc::Float64)
    return 2*atan2(sqrt(1 + ecc)*sin(E/2), sqrt(1 - ecc)*cos(E/2))
end

function truetoecc(T::Float64, ecc::Float64)
    return 2*atan2(sqrt(1 - ecc)*sin(T/2), sqrt(1 + ecc)*cos(T/2))
end

function period(a, mu)
    return sqrt(4*a^3*pi^2/mu)
end

function kepler(ele::Vector, dt::Float64, mu::Float64)
    E0 = truetoecc(ele[6], ele[2])
    M0 = ecctomean(E0, ele[2])
    n = 2*pi/period(ele[1], mu)
    M = M0 + n*dt
    E = meantoecc(M, ele[2])
    T = ecctotrue(E, ele[2])
    return [ele[1:5], T]
end

function kepler(ele::Vector, dt::Vector, mu::Float64)
    out = Array(Float64, length(dt), 6)
    for i = 1:length(dt)
        out[i,:] = kepler(ele, dt[i], mu)
    end
    return out
end
