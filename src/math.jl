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

function rotate_x(angle::Float64)
    mat = zeros(3, 3)
    mat[1,1] = 1
    mat[2,2] = cos(angle)
    mat[2,3] = -sin(angle)
    mat[3,2] = sin(angle)
    mat[3,3] = cos(angle)
    return mat
end

function rotate_y(angle::Float64)
    mat = zeros(3, 3)
    mat[1,1] = cos(angle)
    mat[1,3] = -sin(angle)
    mat[2,2] = 1
    mat[3,1] = sin(angle)
    mat[3,3] = cos(angle)
    return mat
end

function rotate_z(angle::Float64)
    mat = zeros(3, 3)
    mat[1,1] = cos(angle)
    mat[1,2] = -sin(angle)
    mat[2,1] = sin(angle)
    mat[2,2] = cos(angle)
    mat[3,3] = 1
    return mat
end
