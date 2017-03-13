using Documenter, Astrodynamics

makedocs(
    format = :html,
    sitename = "Astrodynamics.jl",
    authors = "Helge Eichhorn",
    pages = [
        "Home" => "index.md",
        "Tutorial" => Any[
            "Epochs and Timescales" => "time.md",
        ],
        "API" => Any[
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
