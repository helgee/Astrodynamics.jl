const JD2000 = 2451544.5
const JD1950 = 2433282.5
const MJD = 2400000.5

function julian(year::Int, month::Int, day::Int, hour::Int, minute::Int, second::Int)
    return julian(year, month, day, hour, minute, float(second))
end

function julian(year::Int, month::Int, day::Int, hour::Int, minute::Int, second::Float64)
    return (367.0 * year - floor((7.0 * (year + floor((month + 9.0) / 12.0))) * 0.25) + floor(275.0 * month / 9.0) + day + 1721013.5 + ((second / 60.0 + minute) / 60.0 + hour) / 24.0)
end

function gregorian(jd::Float64)
    jd += .5
    Z = itrunc(jd)
    F = jd - Z
    if Z < 2299161
        A = Z
    else
        alpha = int((Z - 1867216.25)/36524.25)
        A = Z + 1 + alpha - int(alpha/4)
    end
    B = A + 1524
    C = itrunc((B - 122.1)/365.25)
    D = itrunc(365.25*C)
    E = itrunc((B - D)/30.6001)
    day = ifloor(B - D - itrunc(30.6001*E) + F)
    month = E < 14 ? E-1 : E-13
    year = month > 2 ? C-4716 : C-4715
    t = F*86400
    hmod = mod(t, 3600)
    second = mod(hmod, 60)
    hour = itrunc((t - hmod)/3600)
    minute = itrunc((hmod - second)/60)
    return year, month, day, hour, minute, second
end

function gregorian(jd::Int)
    return gregorian(float(jd))
end

