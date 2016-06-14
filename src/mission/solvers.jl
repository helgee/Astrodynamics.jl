export Solver, NLoptSolver
export minimize, maximize

abstract Solver

type NLoptSolver <: Solver
    algorithm::Symbol
end

function minimize(seg::Segment, objective::Constraint, solver::Solver)
end

function maximize(seg::Segment, objective::Constraint, solver::Solver)
end
