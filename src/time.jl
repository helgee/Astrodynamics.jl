using Compat
using ERFA

import Base: convert, -, +, ==, isless, isapprox, show, string
import Base.Dates: year, month, day, hour, minute, second, millisecond

export Epoch, Timescale
export EpochDelta
export dut1, leapseconds
export days, centuries, seconds
export juliandate, jd2000, jd1950
export JULIAN_CENTURY, SEC_PER_DAY, SEC_PER_CENTURY
export J2000, J1950, MJD
export rad2dms, dms2rad, string

const JULIAN_CENTURY = 36525
const SEC_PER_DAY = 86400
const SEC_PER_CENTURY = SEC_PER_DAY*JULIAN_CENTURY
const J2000 = Dates.datetime2julian(DateTime(2000, 1, 1, 12, 0, 0))
const J1950 = Dates.datetime2julian(DateTime(1950, 1, 1, 12, 0, 0))
const MJD = 2400000.5

abstract Timescale

abstract TT <: Timescale

abstract TDB <: TT
abstract TCB <: TDB

abstract TCG <: TT

abstract TAI <: TT
abstract UTC <: TAI
abstract UT1 <: UTC

type Epoch{T<:Timescale}
    scale::Type{T}
    jd::Float64
    jd1::Float64
    leapseconds::Float64
    ΔUT1::Float64
end

type EpochDelta
    jd::Float64
    jd1::Float64
end

function show{T}(io::IO, ep::Epoch{T})
    print(io, "$(Dates.format(DateTime(ep), "yyyy-mm-ddTHH:MM:SS.sss")) $(Base.datatype_name(T))")
end

EpochDelta(;days::Int=0, seconds::Real=0) = EpochDelta(days, seconds/SEC_PER_DAY)

seconds(ed::EpochDelta) = (ed.jd+ed.jd1)*SEC_PER_DAY
days(ed::EpochDelta) = ed.jd+ed.jd1
isapprox(ed1::EpochDelta, ed2::EpochDelta) = days(ed1) ≈ days(ed2)
(==)(ed1::EpochDelta, ed2::EpochDelta) = days(ed1) == days(ed2)

isless{T<:Timescale}(ep1::Epoch{T}, ep2::Epoch{T}) = juliandate(ep1) < juliandate(ep2)
(-){T<:Timescale}(ep1::Epoch{T}, ep2::Epoch{T}) = EpochDelta(ep1.jd-ep2.jd, ep1.jd1-ep2.jd1)
(-){T<:Timescale}(ep::Epoch{T}, ed::EpochDelta) = Epoch(T, ep.jd-ed.jd, ep.jd1-ed.jd1)
(+){T<:Timescale}(ep::Epoch{T}, ed::EpochDelta) = Epoch(T, ep.jd+ed.jd, ep.jd1+ed.jd1)

function Epoch{T<:Timescale}(scale::Type{T}, jd::Float64, jd1::Float64=0.0)
    ΔUT1 = interpolate(DATA.dut1, jd - MJD + jd1, true, false)[1]
    Epoch(scale, jd, jd1, leapseconds(jd+jd1), ΔUT1)
end

function Epoch{T<:Timescale}(scale::Type{T}, year::Int, month::Int, day::Int,
    hour::Int=0, minute::Int=0, seconds::Float64=0.0)
    jd, jd1 = eraDtf2d(string(T),
    year, month, day, hour, minute, seconds)
    Epoch(scale, jd, jd1)
end

function Epoch{T<:Timescale}(scale::Type{T}, dt::DateTime)
    Epoch(scale, year(dt), month(dt), day(dt),
        hour(dt), minute(dt), second(dt) + millisecond(dt)/1000)
end

Epoch{T<:Timescale}(scale::Type{T}, str::AbstractString) = Epoch(scale, DateTime(str))

function isapprox{T<:Timescale}(a::Epoch{T}, b::Epoch{T})
    return juliandate(a) ≈ juliandate(b)
end

function (==){T<:Timescale}(a::Epoch{T}, b::Epoch{T})
    return DateTime(a) == DateTime(b)
end

leapseconds(ep::Epoch) = ep.leapseconds
dut1(ep::Epoch) = ep.ΔUT1
juliandate(ep::Epoch) = ep.jd + ep.jd1
mjd(ep::Epoch) = juliandate(ep) - MJD
jd2000(ep::Epoch) = juliandate(ep) - J2000
jd1950(ep::Epoch) = juliandate(ep) - J1950
jd(ep::Epoch) = ep.jd
jd1(ep::Epoch) = ep.jd1

scales = (:TT, :TDB, :TCB, :TCG, :TAI, :UTC, :UT1)
for scale in scales
    sym = Symbol(scale, "Epoch")
    name = string(scale)
    @eval begin
        typealias $sym Epoch{$scale}
        export $sym, $scale
        #= show(io::IO, ::Type{$scale}) = print(io, $name) =#
        #= string(::Type{$scale}) = $name =#
    end
end
# Constructor for typealiases
@compat (::Type{Epoch{T}}){T<:Timescale}(a::Union{Real, DateTime, Epoch, AbstractString}, args...) = Epoch(T, a, args...)

Epoch{T<:Timescale, S<:Timescale}(::Type{T}, ep::Epoch{S}) = convert(Epoch{T}, ep)

convert{T<:Timescale}(::Type{Epoch{T}}, ep::Epoch{T}) = ep

function deltat(ep::Epoch)
    leapsec = leapseconds(ep)
    ΔUT1 = dut1(ep)
    32.184 + leapsec - ΔUT1
end

function deltatr(ep::Epoch)
    eraDtdb(jd(ep), jd1(ep), 0.0, 0.0, 0.0, 0.0)
end

function convert{T}(::Type{DateTime}, ep::Epoch{T})
    dt = eraD2dtf(string(T), 3, jd(ep), jd1(ep))
    DateTime(dt...)
end
DateTime(ep::Epoch) = convert(DateTime, ep)

# TAI <-> UTC
function convert(::Type{TAIEpoch}, ep::UTCEpoch)
    date, date1 = eraUtctai(ep.jd, ep.jd1)
    TAIEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

function convert(::Type{UTCEpoch}, ep::TAIEpoch)
    date, date1 = eraTaiutc(ep.jd, ep.jd1)
    UTCEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

# UTC <-> UT1
function convert(::Type{UTCEpoch}, ep::UT1Epoch)
    date, date1 = eraUt1utc(ep.jd, ep.jd1, dut1(ep))
    UTCEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

function convert(::Type{UT1Epoch}, ep::UTCEpoch)
    date, date1 = eraUtcut1(ep.jd, ep.jd1, dut1(ep))
    UT1Epoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

# TAI <-> UT1
function convert(::Type{TAIEpoch}, ep::UT1Epoch)
    date, date1 = eraUt1tai(ep.jd, ep.jd1, dut1(ep)-leapseconds(ep))
    TAIEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

function convert(::Type{UT1Epoch}, ep::TAIEpoch)
    date, date1 = eraTaiut1(ep.jd, ep.jd1, dut1(ep)-leapseconds(ep))
    UT1Epoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

# TT <-> UT1
function convert(::Type{TTEpoch}, ep::UT1Epoch)
    dt = deltat(ep)
    date, date1 = eraUt1tt(ep.jd, ep.jd1, dt)
    TTEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

function convert(::Type{UT1Epoch}, ep::TTEpoch)
    dt = deltat(ep)
    date, date1 = eraTtut1(ep.jd, ep.jd1, dt)
    UT1Epoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

# TAI <-> TT
function convert(::Type{TAIEpoch}, ep::TTEpoch)
    date, date1 = eraTttai(ep.jd, ep.jd1)
    TAIEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

function convert(::Type{TTEpoch}, ep::TAIEpoch)
    date, date1 = eraTaitt(ep.jd, ep.jd1)
    TTEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

# TT <-> TCG
function convert(::Type{TTEpoch}, ep::TCGEpoch)
    date, date1 = eraTcgtt(ep.jd, ep.jd1)
    TTEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

function convert(::Type{TCGEpoch}, ep::TTEpoch)
    date, date1 = eraTttcg(ep.jd, ep.jd1)
    TCGEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

# TT <-> TDB
function convert(::Type{TTEpoch}, ep::TDBEpoch)
    Δtr = deltatr(ep)
    date, date1 = eraTdbtt(ep.jd, ep.jd1, Δtr)
    TTEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

function convert(::Type{TDBEpoch}, ep::TTEpoch)
    Δtr = deltatr(ep)
    date, date1 = eraTttdb(ep.jd, ep.jd1, Δtr)
    TDBEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

# TDB <-> TCB
function convert(::Type{TDBEpoch}, ep::TCBEpoch)
    date, date1 = eraTcbtdb(ep.jd, ep.jd1)
    TDBEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

function convert(::Type{TCBEpoch}, ep::TDBEpoch)
    date, date1 = eraTdbtcb(ep.jd, ep.jd1)
    TCBEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

@generated function convert{T<:Timescale,S<:Timescale}(::Type{Epoch{T}}, obj::Epoch{S})
    convert_generator(T, S, obj)
end

function convert_generator(T, S, obj)
    ex = :(obj)
    path = findpath(S, T, Timescale)
    if length(path) == 2
        error("Please provide a method Base.convert(::Type{Astrodynamics.Epoch{$T}}, ::Astrodynamics.Epoch{$S}).")
    end
    for t in path[2:end]
        ex = :(convert(Epoch{$t}, $ex))
    end
    return :($ex)
end

function dms2rad(deg, arcmin, arcsec)
    deg2rad(deg + arcmin/60 + arcsec/3600)
end

function rad2dms(rad)
    d = rad2deg(rad)
    deg = trunc(d)
    arcmin = trunc((d-deg)*60)
    arcsec = (d-deg-arcmin/60)*3600
    return deg, arcmin, arcsec
end

centuries(ep::Epoch, base=J2000) = (juliandate(ep) - base)/JULIAN_CENTURY
days(ep::Epoch, base=J2000) = juliandate(ep) - base
seconds(ep::Epoch, base=J2000) = (juliandate(ep) - base)*86400

type LSK
    t::Vector{DateTime}
    leapseconds::Vector{Float64}
end

function LSK(file)
    t = Vector{DateTime}()
    leapseconds = Vector{Float64}()
    re = r"(?<dat>[0-9]{2}),\s+@(?<date>[0-9]{4}-[A-Z]{3}-[0-9])"
    lines = open(readlines, file)
    for line in lines
        s = string(line)
        if ismatch(re, s)
            m = match(re, s)
            push!(leapseconds, float(m["dat"]))
            push!(t, DateTime(m["date"], "y-u-d"))
        end
    end
    LSK(t, leapseconds)
end

function fractionofday(dt)
    hour(dt)/24 + minute(dt)/(24*60) + second(dt)/86400 + millisecond(dt)/8.64e7
end

function leapseconds(lsk::LSK, dt::DateTime)
    if dt < DateTime(1960, 1, 1)
        return 0.0
    elseif dt < lsk.t[1]
        return eraDat(year(dt), month(dt), day(dt), fractionofday(dt))
    else
        return lsk.leapseconds[findlast(dt .>= lsk.t)]
    end
end
leapseconds(dt::DateTime) = leapseconds(DATA.leapseconds, dt)
leapseconds(jd::Float64) = leapseconds(DATA.leapseconds, julian2datetime(jd))
