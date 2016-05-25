using Interpolations

import Interpolations: BSplineInterpolation, interpolate
import Base.Dates: julian2datetime

abstract IERSData

JD = 8:15
PMX = 19:27
PMY = 38:46
DUT = 59:68
DPSI_DX = 98:106
DEPS_DY = 117:125


function datecheck(d::IERSData, mjd::Float64, warnings=true)
    if mjd < d.mjd0
        result = :below
    elseif mjd > d.mjd0 + length(d.v1)
        result = :above
    else
        result = :inrange
    end
    if result != :inrange && warnings
        warn("No IERS data is available for $(julian2datetime(mjd+MJD)). Results may be inaccurate.")
    end
    return result
end

type PolarMotion <: IERSData
    mjd0::Float64
    v1::BSplineInterpolation
    v2::BSplineInterpolation
end

type IAU1980 <: IERSData
    mjd0::Float64
    v1::BSplineInterpolation
    v2::BSplineInterpolation
end

type IAU2000 <: IERSData
    mjd0::Float64
    v1::BSplineInterpolation
    v2::BSplineInterpolation
end

function interpolate(d::IERSData, ep::Epoch)
    date = mjd(ep)
    result = datecheck(d, date)
    if result == :below
        return d.v1[1], d.v2[1]
    elseif result == :above
        return d.v1[end], d.v2[end]
    else
        t = date - d.mjd0 + 1
        return d.v1[t], d.v2[t]
    end
end

type DUT1 <: IERSData
    mjd0::Float64
    v1::BSplineInterpolation
end

function interpolate(d::DUT1, mjd::Float64)
    result = datecheck(d, mjd, false)
    if result == :below
        return 0.0
    elseif result == :above
        return d.v1[end]
    else
        return d.v1[mjd - d.mjd0 + 1]
    end
end

isnotnull(line, range) = isnumber(line[range[end]])

function load_iers(iau1980, iau2000)
    lines = open(readlines, iau1980)
    mjd0 = float(lines[1][JD])
    xp = Vector{Float64}()
    yp = Vector{Float64}()
    ΔUT1 = Vector{Float64}()
    δψ = Vector{Float64}()
    δϵ = Vector{Float64}()
    δx = Vector{Float64}()
    δy = Vector{Float64}()
    for line in lines
        if isnotnull(line, PMX)
            push!(xp, dms2rad(0, 0, float(line[PMX])))
        end
        if isnotnull(line, PMY)
            push!(yp, dms2rad(0, 0, float(line[PMY])))
        end
        if isnotnull(line, DUT)
            push!(ΔUT1, float(line[DUT]))
        end
        if isnotnull(line, DPSI_DX)
            push!(δψ, dms2rad(0, 0, float(line[DPSI_DX])/1000))
        end
        if isnotnull(line, DEPS_DY)
            push!(δϵ, dms2rad(0, 0, float(line[DEPS_DY])/1000))
        end
    end
    lines = open(readlines, iau2000)
    for line in lines
        if isnotnull(line, DPSI_DX)
            push!(δx, dms2rad(0, 0, float(line[DPSI_DX])/1000))
        end
        if isnotnull(line, DEPS_DY)
            push!(δy, dms2rad(0, 0, float(line[DEPS_DY])/1000))
        end
    end
    pm = PolarMotion(
        mjd0,
        interpolate(xp, BSpline(Cubic(Line())), OnGrid()),
        interpolate(yp, BSpline(Cubic(Line())), OnGrid()),
    )
    dut1 = DUT1(
        mjd0,
        interpolate(ΔUT1, BSpline(Cubic(Line())), OnGrid()),
    )
    iau80 = IAU1980(
        mjd0,
        interpolate(δψ, BSpline(Cubic(Line())), OnGrid()),
        interpolate(δϵ, BSpline(Cubic(Line())), OnGrid()),
    )
    iau00 = IAU2000(
        mjd0,
        interpolate(δx, BSpline(Cubic(Line())), OnGrid()),
        interpolate(δy, BSpline(Cubic(Line())), OnGrid()),
    )
    return pm, dut1, iau80, iau00
end
