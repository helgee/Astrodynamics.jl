export newton, cross_matrix

function newton(x0, func, derivative, maxiter=50, tol=sqrt(eps()))
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

function cross_matrix(v)
    M = zeros(3,3)
    M[1,2] = -v[3]
    M[1,3] = v[2]
    M[2,1] = v[3]
    M[2,3] = -v[1]
    M[3,1] = -v[2]
    M[3,2] = v[1]
    return M
end
