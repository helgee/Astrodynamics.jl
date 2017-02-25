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
    dx=1e-6,
)
    NLoptSolver(algorithm, differences, dx)
end

function f!(x, f, mission, cons)
    setparameters!(mission, x)
    res = propagate(mission)
    for (i, con) in enumerate(cons)
        #= push!(values, evaluate(con, res)) =#
        #= push!(values, scale(evaluate(con, res))) =#
        f[i] = scale(evaluate(con, res))
    end
    #= return sumabs2(values) =#
end

function optimize(optfun, mission, objective::AbstractConstraint, sol::NLoptSolver)
    output = deepcopy(mission)
    initial = values(output)
    opt = Opt(sol.algorithm, length(initial))
    if sol.algorithm == :AUGLAG
        local_opt = Opt(:LD_LBFGS, length(initial))
        xtol_rel!(local_opt, 1e-6)
        xtol_abs!(local_opt, 1e-6)
        #= ftol_abs!(local_opt, 1e-4) =#
        #= maxeval!(local_opt, 100) =#
        local_optimizer!(opt, local_opt)
    end
    xtol_rel!(opt, 1e-4)
    xtol_abs!(opt, 1e-4)
    #= ftol_abs!(opt, eps()) =#
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
            #= equality_constraint!(opt, (x, g) -> nloptconstraint(x, g, sol, mission, con(val)), 1e-8*scale(val)) =#
            equality_constraint!(opt, (x, g) -> nloptconstraint(x, g, sol, mission, con(val)))
        end
    end
end

minimize(mission, objective::AbstractConstraint, sol::NLoptSolver) = optimize(min_objective!, mission, objective, sol)
maximize(mission, objective::AbstractConstraint, sol::NLoptSolver) = optimize(max_objective!, mission, objective, sol)

function gradient(idx, x, dx, diff, val, mission, con)
    p = parameters(mission)[idx]
    old = value(p)
    #= Δx = dx * 10.0^magnitude(upper(p) - lower(p)) =#
    Δx = dx * (1.0 + abs(x[idx]))
    sign = diff == :backward ? -1 : 1
    push!(p, p + sign*Δx)
    res = propagate(mission)
    dval = evaluate(con, res)
    if diff == :central
        push!(p, p - 2Δx)
        res = propagate(mission)
        bval = evaluate(con, res)
        diffval = (dval - bval) / 2Δx
    elseif diff == :forward
        diffval = (dval - val) / Δx
    elseif diff == :backward
        diffval = (val - dval) / Δx
    end
    push!(p, old)
    @show con
    @show val
    @show dval
    @show diffval
    #= println(scale(val)) =#
    #= return scale(diffval) =#
    return diffval
end

function nloptconstraint(x, grad, sol, mission, con)
    setparameters!(mission, x)
    res = propagate(mission)
    val = evaluate(con, res)
    blob = val
    if length(grad) > 0
        params = parameters(mission)
        g(idx) = gradient(idx, x, sol.dx, sol.differences, val, mission, con)
        grad[:] = map(g, 1:length(params))
        params = parameters(mission)
        println(grad)
    end
    #= if verbose =#
        #= println(con) =#
        #= println(val) =#
        #= println(scale(val)) =#
    #= end =#
    return scale(val)
    #= return val =#
end

scale(x) = x/10.0^magnitude(x)

#= function gradient(sol::Solver, idx::Int, x::Vector{Float64}, mission, con::AbstractConstraint) =#
#=     @show con =#
#=     p = parameters(mission) =#
#=     @show p[idx].value =#
#=     dx = sol.dx * (1.0 + abs(x[idx])) =#
#=     dx = sol.dx * 10.0^magnitude(upper(p[idx]) - lower(p[idx])) =#
#=     @show dx =#
#=     if sol.differences == :backward =#
#=         push!(p[idx], x[idx] - dx) =#
#=     else =#
#=         push!(p[idx], x[idx] + dx) =#
#=     end =#
#=     @show p[idx].value =#
#=     res = propagate(mission) =#
#=     val = evaluate(con, res) =#
#=     @show val =#
#=     if sol.differences == :central =#
#=         push!(p[idx], x[idx] - 2dx) =#
#=         res = propagate(mission) =#
#=         bval = evaluate(con, res) =#
#=         @show bval =#
#=         val = (val - bval) / 2dx =#
#=     end =#
#=     @show val =#
#=     push!(p[idx], x[idx]) =#
#=     return val =#
#= end =#
#=  =#
#= function nloptconstraint(x, grad, sol, mission, con) =#
#=     setparameters!(mission, x) =#
#=     g(idx) = gradient(sol, idx, x, mission, con) =#
#=     if length(grad) > 0 =#
#=         grad[:] = pmap(g, 1:length(grad)) =#
#=         #= g = Vector{Any}(length(grad)) =# =#
#=         #= @sync for i in eachindex(grad) =# =#
#=         #=     g[i] = @spawn gradient(sol, i, x, mission, con) =# =#
#=         #= end =# =#
#=         #= for i in eachindex(grad) =# =#
#=         #=     grad[i] = fetch(g[i]) =# =#
#=         #= end =# =#
#=         @show grad[1] =#
#=         @show grad[2] =#
#=     end =#
#=     res = propagate(mission) =#
#=     val = evaluate(con, res) =#
#=     return val =#
#= end =#
