abstract AbstractEvent

type Event <: AbstractEvent
    detect::Function
    update::Function
end

type TimedEvent <: AbstractEvent
    time::Float64
    update::Function
end

type ContinuousEvent <: AbstractEvent
    time::Tuple{Float64, Float64}
    update::Function
end
