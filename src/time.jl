using Base.Dates
using Compat
using ERFA

import Base.convert

export Epoch, Timescale
export dut1, dut1!, leapseconds, leapseconds!
export days, centuries
export juliandate, jd2000, jd1950
export JULIAN_CENTURY, SEC_PER_DAY, SEC_PER_CENTURY
export J2000, J1950
export rad2dms, dms2rad

const JULIAN_CENTURY = 36525
const SEC_PER_DAY = 86400
const SEC_PER_CENTURY = SEC_PER_DAY*JULIAN_CENTURY
const J2000 = Dates.datetime2julian(DateTime(2000, 1, 1, 12, 0, 0))
const J1950 = Dates.datetime2julian(DateTime(1950, 1, 1, 12, 0, 0))

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
    leapseconds::Int
    ΔUT1::Float64
end

Base.eltype{T}(::Type{Epoch{T}}) = T

function Epoch{T<:Timescale}(scale::Type{T}, jd, jd1=0.0, leapseconds=-1, ΔUT1=NaN)
    Epoch(scale, jd, jd1, leapseconds, ΔUT1)
end

function Epoch{T<:Timescale}(scale::Type{T}, year, month, day,
    hour, minute, seconds, leapseconds=-1, ΔUT1=NaN)
    jd, jd1 = eraDtf2d(string(T),
    year, month, day, hour, minute, seconds)
    Epoch(scale, jd, jd1, leapseconds, ΔUT1)
end

function Epoch{T<:Timescale}(scale::Type{T}, dt::DateTime, leapseconds=-1, ΔUT1=NaN)
    Epoch(scale, year(dt), month(dt), day(dt),
        hour(dt), minute(dt), second(dt) + millisecond(dt)/1000,
        leapseconds, ΔUT1)
end

function Base.isapprox{T<:Timescale}(a::Epoch{T}, b::Epoch{T})
    return juliandate(a) ≈ juliandate(b) && a.leapseconds == b.leapseconds && isequal(a.ΔUT1, b.ΔUT1)
end

function leapseconds!(ep::Epoch, leapsec)
    ep.leapseconds = leapsec
    return ep
end

function dut1!(ep::Epoch, ΔUT1::Float64)
    ep.ΔUT1 = ΔUT1
    return ep
end

function leapseconds(ep::Epoch)
    if ep.leapseconds < 0
        error("Leap seconds not set.")
    end
    return ep.leapseconds
end

function dut1(ep::Epoch)
    if isnan(ep.ΔUT1)
        error("ΔUT1 not set.")
    end
    return ep.ΔUT1
end

juliandate(epoch::Epoch) = epoch.jd + epoch.jd1
jd2000(epoch::Epoch) = juliandate(epoch) - J2000
jd1950(epoch::Epoch) = juliandate(epoch) - J1950
jd(epoch::Epoch) = epoch.jd
jd1(epoch::Epoch) = epoch.jd1

scales = (:TT, :TDB, :TCB, :TCG, :TAI, :UTC, :UT1)
for scale in scales
    sym = symbol(scale, "Epoch")
    @eval begin
        typealias $sym Epoch{$scale}
        export $sym, $scale
    end
end
# Constructor for typealiases
@compat (::Type{Epoch{T}}){T<:Timescale}(a::Union{Real, DateTime, Epoch}, args...) = Epoch(T, a, args...)

Epoch{T<:Timescale, S<:Timescale}(::Type{T}, ep::Epoch{S}) = convert(Epoch{T}, ep)
Epoch{T<:Timescale}(::Type{T}, ep::Epoch{T}) = ep

function deltat(ep::Epoch)
    leapsec = leapseconds(ep)
    ΔUT1 = dut1(ep)
    32.184 + leapsec - ΔUT1
end

function deltatr(ep::Epoch)
    eraDtdb(jd(ep), jd1(ep), 0.0, 0.0, 0.0, 0.0)
end

function convert{T}(::Type{DateTime}, ep::Epoch{T})
    dt = eraD2dtf(string(T), 2, jd(ep), jd1(ep))
    DateTime(dt...)
end
Base.DateTime(ep::Epoch) = convert(DateTime, ep)

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
    ΔUT1 = dut1(ep)
    date, date1 = eraUt1utc(ep.jd, ep.jd1, ΔUT1)
    UTCEpoch(date, date1, ep.leapseconds, ΔUT1)
end
function convert(::Type{UT1Epoch}, ep::UTCEpoch)
    ΔUT1 = dut1(ep)
    date, date1 = eraUtcut1(ep.jd, ep.jd1, ΔUT1)
    UT1Epoch(date, date1, ep.leapseconds, ΔUT1)
end
# TAI <-> UT1
function convert(::Type{TAIEpoch}, ep::UT1Epoch)
    leapsec = leapseconds(ep)
    date, date1 = eraUt1tai(ep.jd, ep.jd1, float(leapsec))
    TAIEpoch(date, date1, leapsec, ep.ΔUT1)
end
function convert(::Type{UT1Epoch}, ep::TAIEpoch)
    leapsec = leapseconds(ep)
    date, date1 = eraTaiut1(ep.jd, ep.jd1, float(leapsec))
    UT1Epoch(date, date1, leapsec, ep.ΔUT1)
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
    date, date1 = eraTdbtcb(ep.jd, ep.jd1)
    TDBEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end
function convert(::Type{TCBEpoch}, ep::TDBEpoch)
    date, date1 = eraTcbtdb(ep.jd, ep.jd1)
    TCBEpoch(date, date1, ep.leapseconds, ep.ΔUT1)
end

@generated function convert{T<:Epoch,S<:Timescale}(::Type{T}, obj::Epoch{S})
    convert_generator(T, S, obj)
end

function convert_generator(T, S, obj)
    ex = :(obj)
    path = findpath(S, eltype(T), Timescale)
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
