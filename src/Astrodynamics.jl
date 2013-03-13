module Astrodynamics

    importall Base

    export Epoch, State
    export julian, gregorian, JD2000, JD1950, MJD
    
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

    type State
    end

    include("time.jl")

end
