export keplerian, cartesian

function keplerian(r, v, µ::Float64)
    rm = norm(r)
    vm = norm(v)
    h = cross(r, v)
    hm = norm(h)
    k = [0.0, 0.0, 1.0]
    n = cross(k, h)
    nm = norm(n)
    xi = vm^2/2 - µ/rm
    ec = ((vm^2 - µ/rm)*r - v*dot(r, v))/µ
    ecc = norm(ec)
    if ecc ≈ 1
        sma = hm^2/µ
    else
        sma = -µ/(2*xi)
    end
    inc = acos(h[3]/hm)
    node = acos(n[1]/nm)
    peri = acos(dot(n, ec)/(ecc*nm))
    ano = acos(dot(ec, r)/(ecc*rm))
    if n[2] < 0
        node = mod2pi(node)
    end
    if ec[3] < 0
        peri = mod2pi(peri)
    end
    if dot(r, v) < 0
        ano = mod2pi(ano)
    end
    [sma, ecc, inc, node, peri, ano]
end

function cartesian(sma, ecc, inc, lan, per, ano, mu)
    u = per + ano
    if ecc == 1
        p = sma
    else
        p = sma*(1 - ecc^2)
    end
    r = p/(1 + ecc*cos(ano))
    x = r*(cos(lan)*cos(u) - sin(lan)*cos(inc)*sin(u))
    y = r*(sin(lan)*cos(u) + cos(lan)*cos(inc)*sin(u))
    z = r*sin(inc)*sin(u)
    vr = sqrt(mu/p)*ecc*sin(ano)
    vf = sqrt(mu*p)/r
    vx = ((vr*(cos(lan)*cos(u) - sin(lan)*cos(inc)*sin(u))
        - vf*(cos(lan)*sin(u) + sin(lan)*cos(u)*cos(inc))))
    vy = ((vr*(sin(lan)*cos(u) + cos(lan)*cos(inc)*sin(u))
        - vf*(sin(lan)*sin(u) - cos(lan)*cos(u)*cos(inc))))
    vz = vr*sin(inc)*sin(u) + vf*cos(u)*sin(inc)
    return [x, y, z], [vx, vy, vz]
end

cartesian(el, mu) = cartesian(el..., mu)
