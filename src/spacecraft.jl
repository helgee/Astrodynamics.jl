abstract AbstractSpacecraft

type Spacecraft <: AbstractSpacecraft
    modules::Array{SCModule, 1}
end

type SCModule
end
