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
    return output, val, code
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

function gradient(sol::Solver, idx::Int, x::Vector{Float64}, mission, con::AbstractConstraint)
    p = parameters(mission)
    dx = sol.dx * (1.0 + abs(x[idx]))
    if sol.differences == :backward
        push!(p[idx], x[idx] - dx)
    else
        push!(p[idx], x[idx] + dx)
    end
    res = propagate(mission)
    val = evaluate(con, res)
    if sol.differences == :central
        push!(p[idx], x[idx] - 2dx)
        res = propagate(mission)
        bval = evaluate(con, res)
        val = (val - bval) / 2dx
    end
    push!(p[idx], x[idx])
    return val
end

function nloptconstraint(x, grad, sol, mission, con)
    setparameters!(mission, x)
    g(idx) = gradient(sol, idx, x, mission, con)
    if length(grad) > 0
        grad[:] = pmap(g, 1:length(grad), err_stop=true)
        #= g = Vector{Any}(length(grad)) =#
        #= @sync for i in eachindex(grad) =#
        #=     g[i] = @spawn gradient(sol, i, x, mission, con) =#
        #= end =#
        #= for i in eachindex(grad) =#
        #=     grad[i] = fetch(g[i]) =#
        #= end =#
    end
    res = propagate(mission)
    val = evaluate(con, res)
    return val
end
