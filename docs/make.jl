using Documenter, Astrodynamics

makedocs(
    format = :html,
    sitename = "Astrodynamics.jl",
    authors = "Helge Eichhorn",
    pages = [
        "Home" => "index.md",
    ],
)

deploydocs(
    repo = "github.com/JuliaAstrodynamics/Astrodynamics.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
)
