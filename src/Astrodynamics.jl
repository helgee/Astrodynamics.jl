#= __precompile__() =#

module Astrodynamics

using Reexport
using RemoteFiles

@reexport using AstroDynBase
@reexport using AstroDynCoordinates
@reexport using AstroDynIO
@reexport using AstroDynPlots
@reexport using AstroDynPropagators
@reexport using JPLEphemeris

@RemoteFileSet ephemerides "JPL Ephemerides" begin
    de430 = @RemoteFile "https://naif.jpl.nasa.gov/pub/naif/generic_kernels/spk/planets/de430.bsp"
    de405 = @RemoteFile "https://naif.jpl.nasa.gov/pub/naif/generic_kernels/spk/planets/a_old_versions/de405.bsp"
end

function __init__()
    AstroDynBase.update()
    download(ephemerides)
    load_ephemeris!(SPK, path(ephemerides, :de430))
end

end
