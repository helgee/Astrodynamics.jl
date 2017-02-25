export Propagator
export state, trajectory

import Base: show

abstract Propagator
abstract AbstractModel

include("propagators/kepler.jl")
include("propagators/ode.jl")
