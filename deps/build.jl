installed = nothing
try
    installed = Pkg.installed("AstroDynDev")
end
if installed == nothing
    Pkg.clone("https://github.com/JuliaAstrodynamics/AstroDynDev.jl")
end
using AstroDynDev
AstroDynDev.install("Astrodynamics")
