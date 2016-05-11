if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end
using Astrodynamics

include("elements.jl")
include("kepler.jl")
include("time.jl")
