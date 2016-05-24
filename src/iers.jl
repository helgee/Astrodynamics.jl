using Interpolations

import Interpolations: BSplineInterpolation, interpolate

abstract IERSData

JD = 8:15
PMX = 19:27
PMY = 38:46
DUT = 59:68
DPSI_DX = 98:106
DEPS_DY = 117:125

iersdate(d::IERSData, ep::Epoch) = juliandate(ep) - MJD - d.mjd + 1

type PolarMotion <: IERSData
    mjd::Float64
    xp::BSplineInterpolation
    yp::BSplineInterpolation
end

function interpolate(d::PolarMotion, ep::Epoch)
    t = iersdate(d, ep)
    return d.xp[t], d.yp[t]
end

type DUT1 <: IERSData
    mjd::Float64
    ΔUT1::BSplineInterpolation
end

function interpolate(d::DUT1, ep::Epoch)
    t = iersdate(d, ep)
    return d.ΔUT1[t]
end

type IAU1980 <: IERSData
    mjd::Float64
    δψ::BSplineInterpolation
    δϵ::BSplineInterpolation
end

function interpolate(d::IAU1980, ep::Epoch)
    t = iersdate(d, ep)
    return d.δψ[t], d.δϵ[t]
end

type IAU2000 <: IERSData
    mjd::Float64
    δx::BSplineInterpolation
    δy::BSplineInterpolation
end

function interpolate(d::IAU2000, ep::Epoch)
    t = iersdate(d, ep)
    return d.δx[t], d.δy[t]
end

isnotnull(line, range) = isnumber(line[range[end]])

function load_iers(iau1980, iau2000)
    lines = open(readlines, iau1980)
    mjd = float(lines[1][JD])
    xp = Vector{Float64}()
    yp = Vector{Float64}()
    ΔUT1 = Vector{Float64}()
    δψ = Vector{Float64}()
    δϵ = Vector{Float64}()
    δx = Vector{Float64}()
    δy = Vector{Float64}()
    for line in lines
        if isnotnull(line, PMX)
            push!(xp, float(line[PMX]))
        end
        if isnotnull(line, PMY)
            push!(yp, float(line[PMY]))
        end
        if isnotnull(line, DUT)
            push!(ΔUT1, float(line[DUT]))
        end
        if isnotnull(line, DPSI_DX)
            push!(δψ, float(line[DPSI_DX]))
        end
        if isnotnull(line, DEPS_DY)
            push!(δϵ, float(line[DEPS_DY]))
        end
    end
    lines = open(readlines, iau2000)
    for line in lines
        if isnotnull(line, DPSI_DX)
            push!(δx, float(line[DPSI_DX]))
        end
        if isnotnull(line, DEPS_DY)
            push!(δy, float(line[DEPS_DY]))
        end
    end
    pm = PolarMotion(
        mjd,
        interpolate(xp, BSpline(Cubic(Line())), OnGrid()),
        interpolate(yp, BSpline(Cubic(Line())), OnGrid()),
    )
    dut1 = DUT1(
        mjd,
        interpolate(ΔUT1, BSpline(Cubic(Line())), OnGrid()),
    )
    iau80 = IAU1980(
        mjd,
        interpolate(δψ, BSpline(Cubic(Line())), OnGrid()),
        interpolate(δϵ, BSpline(Cubic(Line())), OnGrid()),
    )
    iau00 = IAU2000(
        mjd,
        interpolate(δx, BSpline(Cubic(Line())), OnGrid()),
        interpolate(δy, BSpline(Cubic(Line())), OnGrid()),
    )
    return pm, dut1, iau80, iau00
end
