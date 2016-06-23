using NLopt

import NLopt: optimize

export Solver, NLoptSolver
export minimize, maximize

abstract Solver

type OptimizationResult
    before::SegmentResult
    after::SegmentResult
    objective::Float64
    values::Vector{Float64}
    code::Symbol
end

type NLoptSolver <: Solver
    algorithm::Symbol
    differences::Symbol
    dx::Float64
end

function NLoptSolver(;
    algorithm=:LD_SLSQP,
    differences=:central,
    dx=sqrt(eps()),
)
    NLoptSolver(algorithm, differences, dx)
end

function optimize(optfun, mission, objective::AbstractConstraint, sol::NLoptSolver)
    output = deepcopy(mission)
    initial = values(output)
    opt = Opt(sol.algorithm, length(initial))
    #= ftol_rel!(opt, 1e-6) =#
    lower_bounds!(opt, lowerbounds(output))
    upper_bounds!(opt, upperbounds(output))
    optfun(opt, (x, g) -> nloptconstraint(x, g, sol, output, objective))
    addconstraints!(opt, output.stop, sol, output)
    val, x, code = optimize(opt, initial)
    setparameters!(output, x)
    before = propagate(mission)
    after = propagate(output)
    OptimizationResult(before, after, val, x, code)
end

function addconstraints!(opt, t::TargetOrbit, sol, mission)
    for element in fieldnames(t)
        if !isnull(getfield(t, element))
            val = get(getfield(t, element))
            con = KEPLERIAN_CONSTRAINTS[element]
            equality_constraint!(opt, (x, g) -> nloptconstraint(x, g, sol, mission, con(val)))
        end
    end
end

minimize(mission, objective::AbstractConstraint, sol::NLoptSolver) = optimize(min_objective!, mission, objective, sol)
maximize(mission, objective::AbstractConstraint, sol::NLoptSolver) = optimize(max_objective!, mission, objective, sol)

function gradient(idx, Δx, diff, val, mission, con)
    p = parameters(mission)[idx]
    if diff == :backward
        push!(p, p - Δx)
    else
        push!(p, p + Δx)
    end
    res = propagate(mission)
    dval = evaluate(con, res)
    if diff == :central
        push!(p, p - 2Δx)
        res = propagate(mission)
        bval = evaluate(con, res)
        val = (dval - bval) / 2Δx
        push!(p, p + Δx)
    elseif diff == :forward
        val = (dval - val) / Δx
        push!(p, p - Δx)
    elseif diff == :backward
        val = (val - dval) / Δx
        push!(p, p + Δx)
    end
    return val
end

function nloptconstraint(x, grad, sol, mission, con)
    setparameters!(mission, x)
    res = propagate(mission)
    val = evaluate(con, res)
    if length(grad) > 0
        params = parameters(mission)
        dx = sol.dx * (1.0 + abs(x))
        g(idx, Δx) = gradient(idx, Δx, sol.differences, val, mission, con)
        grad[:] = pmap(g, 1:length(params), dx)
    end
    if typeof(con) == Eccentricity
        @show con.target
        @show val
    end
    return val
end
