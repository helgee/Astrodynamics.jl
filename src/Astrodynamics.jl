module Astrodynamics

    using Datetime

    importall Base

    export State
    export julian, gregorian, JD2000, JD1950, MJD
    export ecctomean, meantoecc, ecctotrue, truetoecc
    export propagate
    export planets

    immutable State
        rv::Vector
        t::DateTime
        frame::String
        body::String
    end
    
    include("constants.jl")
    include("time.jl")
    include("frames.jl")
    include("math.jl")
    include("kepler.jl")

    iss = State([8.59072560e+02, -4.13720368e+03, 5.29556871e+03, 7.37289205e+00, 2.08223573e+00, 4.39999794e-01],
        datetime(2013,3,18,12,0,0), "eci", "earth")

    function propagate(s::State; method::String="kepler")
       mu = planets[s.body]["mu"] 
       if method == "kepler"
           ele = elements(s.rv, mu)
           tend = period(ele[1], mu)
           dt = [0:tend]
           return cartesian(kepler(ele, dt, mu), mu)
       end
    end
end
