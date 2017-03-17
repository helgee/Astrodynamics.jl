using Documenter, Astrodynamics, AstronomicalTime, AstroDynBase
using AstroDynIO, AstroDynPlots, AstroDynModels, JPLEphemeris

makedocs(
    modules = [AstronomicalTime, AstroDynBase, AstroDynIO, AstroDynPlots,
               AstroDynModels, JPLEphemeris],
    format = :html,
    sitename = "Astrodynamics.jl",
    authors = "Helge Eichhorn",
    pages = [
        "Home" => "index.md",
        "Tutorial" => Any[
            "Epochs and Timescales" => "time.md",
            "State Vectors and Reference Frame Transformations" => "state.md",
            "Propagators and Events" => "propagators.md",
        ],
        "API" => Any[
            "Time" => "api/time.md",
        ],
    ],
)

deploydocs(
    repo = "github.com/JuliaAstrodynamics/Astrodynamics.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
    osname = "linux",
    julia = "0.6",
)
