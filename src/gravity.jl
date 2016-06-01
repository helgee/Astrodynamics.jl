export UniformGravity, J2Gravity

type UniformGravity{C<:CelestialBody} <: AbstractModel
    center::Type{C}
    mu::Float64
end

UniformGravity{C<:CelestialBody}(c::Type{C}) = UniformGravity(C, μ(C))

function gravity!(f::Vector{Float64}, y::Vector{Float64}, model::UniformGravity)
    r = sqrt(y[1]*y[1]+y[2]*y[2]+y[3]*y[3])
    r3 = r*r*r
    f[1] += y[4]
    f[2] += y[5]
    f[3] += y[6]
    f[4] += -model.mu*y[1]/r3
    f[5] += -model.mu*y[2]/r3
    f[6] += -model.mu*y[3]/r3
end

type J2Gravity{C<:CelestialBody} <: AbstractModel
    center::Type{C}
    mu::Float64
    j2::Float64
    mean_radius2::Float64
end

J2Gravity{C<:CelestialBody}(c::Type{C}) = J2Gravity(C, μ(C), j2(C), mean_radius(C)^2)

function gravity!(f::Vector{Float64}, y::Vector{Float64}, model::J2Gravity)
    r = sqrt(y[1]*y[1]+y[2]*y[2]+y[3]*y[3])
    r2 = r*r
    r3 = r2*r
    z2 = y[3]*y[3]
    pj = -3/2 * model.mu * model.j2 * model.mean_radius2 / (r3*r2)

    f[1] += y[4]
    f[2] += y[5]
    f[3] += y[6]
    f[4] += -model.mu*y[1]/r3 + pj * y[1] * (1 - 5 * z2 / r2)
    f[5] += -model.mu*y[2]/r3 + pj * y[2] * (1 - 5 * z2 / r2)
    f[6] += -model.mu*y[3]/r3 + pj * y[3] * (3 - 5 * z2 / r2)
end
