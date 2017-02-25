![Astrodynamics.jl](docs/logo/Astrodynamics-jl-logo.png)

[![Travis](https://img.shields.io/travis/JuliaAstrodynamics/Astrodynamics.jl/master.svg?style=flat)](https://travis-ci.org/JuliaAstrodynamics/Astrodynamics.jl)
[![Coveralls](https://img.shields.io/coveralls/JuliaAstrodynamics/Astrodynamics.jl/master.svg?style=flat)](https://coveralls.io/github/JuliaAstrodynamics/Astrodynamics.jl?branch=master)
[![Codecov](https://img.shields.io/codecov/c/github/JuliaAstrodynamics/Astrodynamics.jl/master.svg?style=flat&label=Codecov)](https://codecov.io/gh/JuliaAstrodynamics/Astrodynamics.jl)

Astrodynamics.jl is an MPLv2-licensed toolbox for the development of astrodynamics software in Julia.

## Installation
This package and most of its dependencies are not yet registered.
To use it you will need to clone the following packages:

```julia
Pkg.clone("https://github.com/JuliaAstrodynamics/AstronomicalTime.jl.git")
Pkg.clone("https://github.com/JuliaAstrodynamics/SPICE.jl.git")
Pkg.clone("https://github.com/JuliaAstrodynamics/AstrodynamicsBase.jl.git")
Pkg.clone("https://github.com/JuliaAstrodynamics/AstrodynamicsIO.jl.git")
Pkg.clone("https://github.com/JuliaAstrodynamics/AstrodynamicsPlots.jl.git")
Pkg.clone("https://github.com/JuliaAstrodynamics/AstrodynamicsModels.jl.git")
Pkg.clone("https://github.com/JuliaAstrodynamics/Astrodynamics.jl.git")

Pkg.checkout("Dopri")
Pkg.checkout("JPLEphemeris")
```
