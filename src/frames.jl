export AbstractFrame, IAURotating, IAUInertial
export ECI, ECEF, SEZ
export GCRF, CIRF, TIRF, ITRF

abstract AbstractFrame

abstract GCRF <: AbstractFrame
abstract CIRF <: GCRF
abstract TIRF <: CIRF
abstract ITRF <: TIRF

abstract ECI <: GCRF
abstract ECEF <: ECI
abstract SEZ <: ECI

abstract IAURotating{T<:Planet} <: GCRF
abstract IAUInertial{T<:Planet} <: GCRF

function neighbors(t::DataType)
    supertype = super(t)
    if supertype == AbstractFrame
        return subtypes(t)
    else
        return push!(subtypes(t), supertype)
    end
end

function findpath(origin::DataType, target::DataType)
    queue = [origin]
    links = Dict{DataType, DataType}()
    while !isempty(queue)
        node = shift!(queue)
        if node == target
            break
        end
        for n in neighbors(node)
            if !haskey(links, n)
                push!(queue, n)
                merge!(links, Dict{DataType, DataType}(n=>node))
            end
        end
    end
    if !haskey(links, target)
        error("No frame conversion path '$origin' -> '$target' found.")
    end
    path = [target]
    node = target
    while node != origin
        push!(path, links[node])
        node = links[node]
    end
    return reverse(path)
end

function elements(rv::Vector, mu::Float64)
    r, v = rv[1:3], rv[4:6]
    rm = norm(r)
    vm = norm(v)
    h = cross(r, v)
    hm = norm(h)
    k = [0, 0, 1]
    n = cross(k, h)
    nm = norm(n)
    xi = vm^2/2 - mu/rm
    ec = ((vm^2 - mu/rm)*r - v*dot(r, v))/mu
    ecc = norm(ec)
    if ecc != 1
        sma = -mu/(2*xi)
        p = sma*(1-ecc^2)
    else
        p = hm^2/mu
        sma = p
    end
    inc = acos(h[3]/hm)
    node = acos(n[1]/nm)
    peri = acos(dot(n, ec)/(ecc*nm))
    ano = acos(dot(ec, r)/(ecc*rm))
    if n[2] < 0
        node = 2*pi - node
    end
    if ec[3] < 0
        peri = 2*pi - peri
    end
    if dot(r, v) < 0
        ano = 2*pi - ano
    end
    return [sma, ecc, inc, node, peri, ano]
end

function elements(rv::Matrix, mu::Float64)
    m, n = size(rv)
    if m != 6 && n != 6
        error("'rv' must be a 6xN or Nx6 matrix.")
    elseif m == 6
        rv = rv'
        m, n = n, m
    end
    ele = zeros(m,n)
    for i = 1:m
        ele[i,:] = elements(vec(rv[i,:]), mu)
    end
    return ele
end

function cartesian(ele::Vector, mu::Float64)
    sma, ecc, inc, lan, per, ano = ele
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
    return [x, y, z, vx, vy, vz]
end

function cartesian(ele::Matrix, mu::Float64)
    m, n = size(ele)
    if m != 6 && n != 6
        error("'ele' must be a 6xN or Nx6 matrix.")
    elseif m == 6
        ele = ele'
        m, n = n, m
    end
    rv = zeros(m,n)
    for i = 1:m
        rv[i,:] = cartesian(vec(ele[i,:]), mu)
    end
    return rv
end
