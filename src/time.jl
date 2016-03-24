using Base.Dates
using ERFA

import Base.convert, Base.promote_rule

export Epoch, AbstractTimescale
export juliandate, jd2000, jd1950#, mjd
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

names = Dict{DataType, ASCIIString}(
    TT => "TT",
    TDB => "TDB",
    TCB => "TCB",
    TAI => "TAI",
    UTC => "UTC",
    UT1 => "UT1",
)

type Epoch{T<:Timescale}
    scale::Type{T}
    jd::Float64
    jd1::Float64
    dat::Int
    dut1::Float64
end

Base.eltype{T}(::Type{Epoch{T}}) = T

function Epoch{T<:Timescale}(scale::Type{T}, jd::Float64, jd1::Float64=0.0;
    dat::Int=-1, dut1::Float64=NaN)
    Epoch(scale, jd, jd1, dat, dut1)
end

function Epoch{T<:Timescale}(scale::Type{T}, year::Int, month::Int, day::Int,
    hour::Int, minute::Int, seconds::Float64;
    dat::Int=-1, dut1::Float64=NaN)
    jd, jd1 = eraDtf2d(names[scale],
    year, month, day, hour, minute, seconds)
    Epoch(scale, jd, jd1, dat=dat, dut1=dut1)
end

function Epoch{T<:Timescale}(scale::Type{T}, year::Int, month::Int, day::Int,
    hour::Int, minute::Int, seconds::Int;
    dat::Int=-1, dut1::Float64=NaN)
    Epoch(scale, year, month, day, hour, minute, float(seconds), dat=dat, dut1=dut1)
end

function Epoch{T<:Timescale}(scale::Type{T}, dt::DateTime;
    dat::Int=-1, dut1::Float64=NaN)
    Epoch(scale, year(dt), month(dt), day(dt),
        hour(dt), minute(dt), second(dt) + millisecond(dt)/1000,
        dat=dat, dut1=dut1)
end

function setleapseconds!(ep::Epoch, dat::Int)
    ep.dat = dat
    return ep
end

function setdut1!(ep::Epoch, dut1::Float64)
    ep.dut1 = dut1
    return ep
end

function getleapseconds(ep::Epoch)
    if ep.dat < 0
        error("Leap seconds not set. Conversion failed.")
    else
        return get(ep.dat)
    end
end

function getdut1(ep::Epoch)
    if isnan(ep.dut1)
        error("'dut1' not set. Conversion failed.")
    else
        return get(ep.dut1)
    end
end

juliandate(epoch::Epoch) = epoch.jd + epoch.jd1
jd2000(epoch::Epoch) = juliandate(epoch) - J2000
jd1950(epoch::Epoch) = juliandate(epoch) - J1950
jd(epoch::Epoch) = epoch.jd
jd1(epoch::Epoch) = epoch.jd1
dat(epoch::Epoch) = epoch.dat
dut1(epoch::Epoch) = epoch.dut1

scales = (:TT, :TDB, :TCB, :TCG, :TAI, :UTC, :UT1)
for scale in scales
    sym = symbol(scale, "Epoch")
    @eval begin
        typealias $sym Epoch{$scale}
        export $sym, $scale
    end
end
# Constructor for typealiases
Base.call{T<:Timescale}(::Type{Epoch{T}}, args...; kwargs...) = Epoch(T, args...; kwargs...)

Epoch{T<:Timescale}(::Type{T}, ep::Epoch) = convert(Epoch{T}, ep)

function deltat(ep::Epoch)
    dat = getleapseconds(ep)
    dut1 = getdut1(ep)
    32.184 + dat - dut1
end

function deltatr(ep::Epoch)
    eraDtdb(jd(ep), jd1(ep), 0.0, 0.0, 0.0, 0.0)
end

function convert{T}(::Type{DateTime}, ep::Epoch{T})
    dt = eraD2dtf(names[T], 2, jd(ep), jd1(ep))
    DateTime(dt...)
end
Base.DateTime(ep::Epoch) = convert(DateTime, ep)

# TAI <-> UTC
function convert(::Type{TAIEpoch}, ep::UTCEpoch)
    date, date1 = eraUtctai(jd(ep), jd1(ep))
    TAIEpoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
function convert(::Type{UTCEpoch}, ep::TAIEpoch)
    date, date1 = eraTaiutc(jd(ep), jd1(ep))
    UTCEpoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
# UTC <-> UT1
function convert(::Type{UTCEpoch}, ep::UT1Epoch)
    dut1 = getdut1(ep)
    date, date1 = eraUt1utc(jd(ep), jd1(ep), dut1)
    UTCEpoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
function convert(::Type{UT1Epoch}, ep::UTCEpoch)
    dut1 = getdut1(ep)
    date, date1 = eraUtcut1(jd(ep), jd1(ep), dut1)
    UT1Epoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
# TAI <-> UT1
function convert(::Type{TAIEpoch}, ep::UT1Epoch)
    dat = getleapseconds(ep)
    date, date1 = eraUt1tai(jd(ep), jd1(ep), dat)
    TAIEpoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
function convert(::Type{UT1Epoch}, ep::TAIEpoch)
    dat = getleapseconds(ep)
    date, date1 = eraTaiut1(jd(ep), jd1(ep), dat)
    UT1Epoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
# TT <-> UT1
function convert(::Type{TTEpoch}, ep::UT1Epoch)
    dt = deltat(ep)
    date, date1 = eraUt1tt(jd(ep), jd1(ep), dt)
    TTEpoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
function convert(::Type{UT1Epoch}, ep::TTEpoch)
    dt = deltat(ep)
    date, date1 = eraTtut1(jd(ep), jd1(ep), dt)
    UT1Epoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
# TAI <-> TT
function convert(::Type{TAIEpoch}, ep::TTEpoch)
    date, date1 = eraTttai(jd(ep), jd1(ep))
    TAIEpoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
function convert(::Type{TTEpoch}, ep::TAIEpoch)
    date, date1 = eraTaitt(jd(ep), jd1(ep))
    UTCEpoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
# TT <-> TCG
function convert(::Type{TTEpoch}, ep::TCGEpoch)
    date, date1 = eraTcgtt(jd(ep), jd1(ep))
    TTEpoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
function convert(::Type{TCGEpoch}, ep::TTEpoch)
    date, date1 = eraTttcg(jd(ep), jd1(ep))
    TCGEpoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
# TT <-> TDB
function convert(::Type{TTEpoch}, ep::TDBEpoch)
    dtr = deltatr(ep)
    date, date1 = eraTdbtt(jd(ep), jd1(ep), dtr)
    TTEpoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
function convert(::Type{TDBEpoch}, ep::TTEpoch)
    dtr = deltatr(ep)
    date, date1 = eraTttdb(jd(ep), jd1(ep), dtr)
    TDBEpoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
# TDB <-> TCB
function convert(::Type{TDBEpoch}, ep::TCBEpoch)
    date, date1 = eraTdbtcb(jd(ep), jd1(ep))
    TDBEpoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end
function convert(::Type{TCBEpoch}, ep::TDBEpoch)
    date, date1 = eraTcbtdb(jd(ep), jd1(ep))
    TCBEpoch(date, date1, dat=dat(ep), dut1=dut1(ep))
end

@generated function convert{T<:Epoch,S}(::Type{T}, obj::Epoch{S})
    ex = :(obj)
    if eltype(T) == S
        return :($ex)
    end
    path = findpath(S, eltype(T))
    for t in path[2:end]
        ex = :(convert(Epoch{$t}, $ex))
    end
    return :($ex)
end

function dms2rad(deg::Real, arcmin::Real, arcsec::Real)
    deg2rad(deg + arcmin/60 + arcsec/3600)
end

function rad2dms(rad::Real)
    d = rad2deg(rad)
    deg = trunc(d)
    arcmin = trunc((d-deg)*60)
    arcsec = (d-deg-arcmin/60)*3600
    return deg, arcmin, arcsec
end

centuries(ep::Epoch, base::Float64=J2000) = (juliandate(ep) - base)/JULIAN_CENTURY
days(ep::Epoch, base::Float64=J2000) = juliandate(ep) - base
