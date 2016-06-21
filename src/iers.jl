using Dierckx

import Base.Dates: julian2datetime

JD = 8:15
PMX = 19:27
PMY = 38:46
DUT = 59:68
DPSI_DX = 98:106
DEPS_DY = 117:125

type IERSData
    dtype::Symbol
    dates::Vector{Float64}
    v1::Spline1D
    v2::Nullable{Spline1D}
    IERSData(dtype, dates, v1, v2=Nullable{Spline1D}()) = new(dtype, dates, v1, v2)
end

function datecheck(d::IERSData, mjd::Float64, warn_above, warn_below)
    if mjd < d.dates[1] && warn_below
        warn("No IERS data is available before $(julian2datetime(d.dates[1]+MJD)). Results may be inaccurate.")
    elseif mjd > d.dates[end] && warn_above
        warn("No IERS data is available after $(julian2datetime(d.dates[end]+MJD)). Results may be inaccurate.")
    end
end

function interpolate(d::IERSData, date::Float64, warn_above=true, warn_below=true)
    datecheck(d, date, warn_above, warn_below)
    v1 = evaluate(d.v1, date)
    v2 = 0.0
    if !isnull(d.v2)
        v2 = evaluate(get(d.v2), date)
    end
    return v1, v2
end
interpolate(d::IERSData, ep::Epoch) = interpolate(d, mjd(ep))

isnotnull(line, range) = isnumber(line[range[end]])

function load_iers(iau1980, iau2000)
    lines = open(readlines, iau1980)
    dates = Vector{Float64}()
    xp = Vector{Float64}()
    yp = Vector{Float64}()
    ΔUT1 = Vector{Float64}()
    δψ = Vector{Float64}()
    δϵ = Vector{Float64}()
    δx = Vector{Float64}()
    δy = Vector{Float64}()
    for line in lines
        if isnotnull(line, JD)
            push!(dates, float(line[JD]))
        end
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
    d = dates[1:length(xp)]
    pm = IERSData(
        :polarmotion,
        d,
        Spline1D(d, xp, bc="zero"),
        Spline1D(d, yp, bc="zero"),
    )
    d = dates[1:length(ΔUT1)]
    dut1 = IERSData(
        :dut1,
        d,
        Spline1D(d, ΔUT1, bc="zero"),
    )
    d = dates[1:length(δψ)]
    iau80 = IERSData(
        :iau1980,
        d,
        Spline1D(d, δψ, bc="zero"),
        Spline1D(d, δϵ, bc="zero"),
    )
    d = dates[1:length(δx)]
    iau00 = IERSData(
        :iau2000,
        d,
        Spline1D(d, δx, bc="zero"),
        Spline1D(d, δy, bc="zero"),
    )
    return pm, dut1, iau80, iau00
end
