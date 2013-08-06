function newton(x0::Float64, func::Function, derivative::Function, maxiter::Int=50, tol::Float64=sqrt(eps()))
    p0 = x0
    for i = 1:maxiter
        i += 1
        p = p0 - func(p0)/derivative(p0)
        if abs(p - p0) < tol
            return p
        end
        p0 = p
    end
    error("Not converged.")
end
