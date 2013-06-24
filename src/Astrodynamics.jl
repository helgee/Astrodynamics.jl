module Astrodynamics

    using Calendar

    importall Base

    export Epoch, State
    export julian, gregorian, JD2000, JD1950, MJD
    export keplertorv, rvtokepler
    
    immutable Epoch
        year::Int
        month::Int
        day::Int
        hour::Int
        minute::Int
        second::Float64
        #microsecond::Int
        #nanosecond::Int
        jd::Float64
        mjd::Float64
        jd2000::Float64
        jd1950::Float64

        function Epoch(year, month, day, hour, minute, second)
            jd = julian(year, month, day, hour, minute, second)
            jd2000 = jd - JD2000
            jd1950 = jd - JD1950
            mjd = jd - MJD
            return new(year, month, day, hour, minute, second, jd, mjd, jd2000, jd1950)
        end
    end

    function Epoch(t::CalendarTime)
        t = tz(t, "UTC")
        return Epoch(year(t), month(t), day(t), hour(t), minute(t), second(t))
    end

    function show(io::IO, ep::Epoch)
        @printf(io, "Date/Time:\t%u-%02u-%02uT%02u:%02u:%02.3fZ\n", ep.year, ep.month, ep.day, ep.hour, ep.minute, ep.second)
        print("JD2000:\t$(ep.jd2000)")
    end

    type State
    end

    include("time.jl")
    include("frames.jl")

end
