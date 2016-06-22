using NLopt

import NLopt: optimize

export Solver, NLoptSolver
export minimize, maximize

abstract Solver

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
    xtol_rel!(opt, 1e-4)
    lower_bounds!(opt, lowerbounds(output))
    upper_bounds!(opt, upperbounds(output))
    optfun(opt, (x, g) -> nloptconstraint(x, g, sol, output, objective))
    addconstraints!(opt, output.stop, sol, output)
    val, x, code = optimize(opt, initial)
    setparameters!(output, x)
    res = propagate(output)
    return res, val, code
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

function gradient(p, Δx, diff, val, mission, con)
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
    elseif diff == :forward
        val = (dval - val) / Δx
    elseif diff == :backward
        val = (val - dval) / Δx
    end
    return val
end

function nloptconstraint(x, grad, sol, mission, con)
    #= params = getparameters(mission) =#
    setparameters!(mission, x)
    res = propagate(mission)
    val = evaluate(con, res)
    if length(grad) > 0
        params = parameters(mission)
        dx = sol.dx * (1.0 + abs(x))
        g(p, Δx) = gradient(p, Δx, sol.differences, val, mission, con)
        grad[:] = pmap(g, params, dx)
    end
    return val
end
