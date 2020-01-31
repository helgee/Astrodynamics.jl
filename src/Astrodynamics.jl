#= __precompile__() =#

module Astrodynamics

using Reexport
using RemoteFiles

@reexport using AstroBase
@reexport using AstroDynPlots
@reexport using AstroDynPropagators
@reexport using JPLEphemeris

@RemoteFileSet ephemerides "JPL Ephemerides" begin
    de430 = @RemoteFile "https://naif.jpl.nasa.gov/pub/naif/generic_kernels/spk/planets/de430.bsp"
    de405 = @RemoteFile "https://naif.jpl.nasa.gov/pub/naif/generic_kernels/spk/planets/a_old_versions/de405.bsp"
end

const EPHEMERIS = Ref{SPK}()

AstroBase.State(s::AbstractState; kwargs...) = State(s, EPHEMERIS[]; kwargs...)
# AstroBase.KeplerianState(s::AbstractState; kwargs...) = KeplerianState(State(s, EPHEMERIS[], kwargs...))
AstroDynPropagators.ThirdBody(bodies...) = ThirdBody(EPHEMERIS[], collect(bodies))

function __init__()
    AstroTime.update()
    download(ephemerides)
    EPHEMERIS[] = SPK(path(ephemerides, :de430))
    nothing
end

end
