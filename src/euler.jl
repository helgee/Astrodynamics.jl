export euler2dcm, euler2dcm!, rates2dcm, rates2dcm!

function euler2dcm(sequence::Int, ang1, ang2, ang3)
    m = Array(Float64, 3, 3)
    euler2dcm!(sequence, m, ang1, ang2, ang3)
end

function euler2dcm!(sequence::Int, m, ang1, ang2, ang3)
    s1 = sin(ang1)
    c1 = cos(ang1)
    s2 = sin(ang2)
    c2 = cos(ang2)
    s3 = sin(ang3)
    c3 = cos(ang3)
    euler2dcm!(Val{sequence}, m, s1, c1, s2, c2, s3, c3)
end

function rates2dcm(sequence::Int, ang1, ang2, ang3, dang1, dang2, dang3)
    m = zeros(Float64, 3, 3)
    rates2dcm!(sequence, m, ang1, ang2, ang3, dang1, dang2, dang3)
end

function rates2dcm!(sequence::Int, m, ang1, ang2, ang3, dang1, dang2, dang3)
    s1 = sin(ang1)
    c1 = cos(ang1)
    s2 = sin(ang2)
    c2 = cos(ang2)
    s3 = sin(ang3)
    c3 = cos(ang3)
    rates = dang1*dang2*dang3
    rates2dcm!(Val{sequence}, m, s1, c1, s2, c2, s3, c3, rates)
end

function euler2dcm!(::Type{Val{321}}, m, s1, c1, s2, c2, s3, c3)
    m[1,1] = c2*c1
    m[1,2] = c2*s1
    m[1,3] = -s2
    m[2,1] = s3*s2*c1 - c3*s1
    m[2,2] = s3*s2*s1 + c3*c1
    m[2,3] = s3*c2
    m[3,1] = c3*s2*c1 + s3*s1
    m[3,2] = c3*s2*s1 - s3*c1
    m[3,3] = c3*c2
    return m
end

function rates2dcm!(::Type{Val{321}}, m, s1, c1, s2, c2, s3, c3, rates)
    m[2,1] = rates*s1*c2*c3
    m[2,2] = -rates*c1*c3*c3
    m[3,1] = -rates*s1*c2*s3
    m[3,2] = rates*c1*c2*s3
    return m
end

function euler2dcm!(::Type{Val{121}}, m, s1, c1, s2, c2, s3, c3)
    m[1,1] = c2
    m[1,2] = -s1*s2
    m[1,3] = -c1*s2
    m[2,1] = -s2*s3
    m[2,2] = -s1*c2*s3 + c1*c3
    m[2,3] = -c1*c2*s3 - s1*c3
    m[3,1] = s2*c3
    m[3,2] = s1*c2*c3 + c1*s3
    m[3,3] = c1*c2*c3 - s1*c3
    return m
end

function rates2dcm!(::Type{Val{121}}, m, s1, c1, s2, c2, s3, c3, rates)
    m[2,2] = rates*c1*s2*c3
    m[2,3] = rates*s1*s2*c3
    m[3,2] = -rates*c1*s2*s3
    m[3,3] = -rates*s1*s2*s3
    return m
end

function euler2dcm!(::Type{Val{123}}, m, s1, c1, s2, c2, s3, c3)
    m[1,1] = c2*c3
    m[1,2] = s1*s2*c3 + c1*s3
    m[1,3] = -c1*s2*c3 + s1*s3
    m[2,1] = -c2*s3
    m[2,2] = -s1*s2*s3 + c1*c3
    m[2,3] = c1*s2*s3 + s1*c3
    m[3,1] = s2
    m[3,2] = -s1*c2
    m[3,3] = c1*c2
    return m
end

function rates2dcm!(::Type{Val{123}}, m, s1, c1, s2, c2, s3, c3, rates)
    m[1,2] = rates*c1*c2*s3
    m[1,3] = rates*s1*c2*s3
    m[2,2] = rates*c1*c2*c3
    m[2,3] = rates*s1*c2*c3
    return m
end

function euler2dcm!(::Type{Val{131}}, m, s1, c1, s2, c2, s3, c3)
    m[1,1] = c2
    m[1,2] = c1*s2
    m[1,3] = s1*s2
    m[2,1] = -s2*c3
    m[2,2] = c1*c3*c2 - s1*s3
    m[2,3] = s1*c3*c2 + c1*s3
    m[3,1] = s2*s3
    m[3,2] = -c1*c2*s3 - s1*c3
    m[3,3] = -s1*c2*s3 + c1*c3
    return m
end

function rates2dcm!(::Type{Val{131}}, m, s1, c1, s2, c2, s3, c3, rates)
    m[2,2] = -rates*s1*s2*s3
    m[2,3] = rates*c1*s2*s3
    m[3,2] = -rates*s1*s2*c3
    m[3,3] = rates*c1*s2*c3
    return m
end

function euler2dcm!(::Type{Val{132}}, m, s1, c1, s2, c2, s3, c3)
    m[1,1] = c3*c2
    m[1,2] = -c1*c3*s2 - s1*s3
    m[1,3] = s1*c3*s2 - c1*s3
    m[2,1] = s2
    m[2,2] = c1*c2
    m[2,3] = -s1*c2
    m[3,1] = s3*c2
    m[3,2] = -c1*s2*s3 + s1*c3
    m[3,3] = s1*s2*s3 + c1*c3
    return m
end

function rates2dcm!(::Type{Val{132}}, m, s1, c1, s2, c2, s3, c3, rates)
    m[1,2] = rates*s1*c2*s3
    m[1,3] = -rates*c1*c2*s3
    m[3,2] = rates*s1*c2*c3
    m[3,3] = -rates*c1*c2*c3
    return m
end

function euler2dcm!(::Type{Val{212}}, m, s1, c1, s2, c2, s3, c3)
    m[1,1] = -s1*c2*s3 + c1*c3
    m[1,2] = -s2*s3
    m[1,3] = -c1*c2*s3 - s1*c3
    m[2,1] = -s1*s2
    m[2,2] = c2
    m[2,3] = -c1*s2
    m[3,1] = s1*c3*c2 + c1*s3
    m[3,2] = s2*c3
    m[3,3] = c1*c3*c2 - s1*s3
    return m
end

function rates2dcm!(::Type{Val{212}}, m, s1, c1, s2, c2, s3, c3, rates)
    m[1,1] = rates*c1*s2*c3
    m[1,3] = rates*s1*s2*c3
    m[3,1] = -rates*c1*s2*s3
    m[3,3] = -rates*s1*s2*s3
    return m
end

function euler2dcm!(::Type{Val{213}}, m, s1, c1, s2, c2, s3, c3)
    m[1,1] = c1*c3 + s2*s1*s3
    m[1,2] = c2*s3
    m[1,3] = -s1*c3 + s2*c1*s3
    m[2,1] = -c1*s3 + s2*s1*c3
    m[2,2] = c2*c3
    m[2,3] = s1*s3 + s2*c1*c3
    m[3,1] = s1*c2
    m[3,2] = -s2
    m[3,3] = c2*c1
    return m
end

function rates2dcm!(::Type{Val{213}}, m, s1, c1, s2, c2, s3, c3, rates)
    m[1,1] = -rates*c1*c2*c3
    m[1,3] = -rates*s1*c2*c3
    m[2,1] = rates*c1*c2*s3
    m[2,3] = rates*s1*c2*s3
    return m
end

function euler2dcm!(::Type{Val{231}}, m, s1, c1, s2, c2, s3, c3)
    m[1,1] = c1*c2
    m[1,2] = -s2
    m[1,3] = -s1*c2
    m[2,1] = c3*c1*s2 - s3*s1
    m[2,2] = c2*c3
    m[2,3] = -c3*s1*s2 - s3*c1
    m[3,1] = s3*c1*s2 + c3*s1
    m[3,2] = s3*c2
    m[3,3] = -s3*s1*s2 + c3*c1
    return m
end

function rates2dcm!(::Type{Val{231}}, m, s1, c1, s2, c2, s3, c3, rates)
    m[2,1] = -rates*s1*c2*s3
    m[2,3] = rates*c1*c2*s3
    m[3,1] = -rates*s1*c2*c3
    m[3,3] = rates*c1*c2*c3
    return m
end

function euler2dcm!(::Type{Val{232}}, m, s1, c1, s2, c2, s3, c3)
    m[1,1] = c1*c3*c2 - s1*s3
    m[1,2] = s2*c3
    m[1,3] = -s1*c3*c2 - c1*s3
    m[2,1] = -c1*s2
    m[2,2] = c2
    m[2,3] = s1*s2
    m[3,1] = c1*c2*s3 + s1*c3
    m[3,2] = s2*s3
    m[3,3] = -s1*c2*s3 + c1*c3
    return m
end

function rates2dcm!(::Type{Val{232}}, m, s1, c1, s2, c2, s3, c3, rates)
    m[1,1] = -rates*s1*s2*s3
    m[1,3] = rates*c1*s2*s3
    m[3,1] = -rates*s1*s2*c3
    m[3,3] = rates*c1*s2*c3
    return m
end

function euler2dcm!(::Type{Val{312}}, m, s1, c1, s2, c2, s3, c3)
    m[1,1] = c3*c1 - s2*s3*s1
    m[1,2] = c3*s1 + s2*s3*c1
    m[1,3] = -s3*c2
    m[2,1] = -c2*s1
    m[2,2] = c2*c1
    m[2,3] = s2
    m[3,1] = s3*c1 + s2*c3*s1
    m[3,2] = s3*s1 - s2*c3*c1
    m[3,3] = c2*c3
    return m
end

function rates2dcm!(::Type{Val{312}}, m, s1, c1, s2, c2, s3, c3, rates)
    m[1,1] = rates*c1*c2*c3
    m[1,2] = rates*s1*c2*c3
    m[3,1] = -rates*c1*c2*s3
    m[3,2] = -rates*s1*c2*s3
    return m
end

function euler2dcm!(::Type{Val{313}}, m, s1, c1, s2, c2, s3, c3)
    m[1,1] = -s1*c2*s3 + c1*c3
    m[1,2] = c1*c2*s3 + s1*c3
    m[1,3] = s2*s3
    m[2,1] = -s1*c3*c2 - c1*s3
    m[2,2] = c1*c3*c2 - s1*s3
    m[2,3] = s2*c3
    m[3,1] = s1*s2
    m[3,2] = -c1*s2
    m[3,3] = c2
    return m
end

function rates2dcm!(::Type{Val{313}}, m, s1, c1, s2, c2, s3, c3, rates)
    m[1,1] = rates*c1*s2*c3
    m[1,2] = rates*s1*s2*c3
    m[2,1] = -rates*c1*s2*s3
    m[2,2] = -rates*s1*s2*s3
    return m
end

function euler2dcm!(::Type{Val{323}}, m, s1, c1, s2, c2, s3, c3)
    m[1,1] = c1*c3*c2 - s1*s3
    m[1,2] = s1*c3*c2 + c1*s3
    m[1,3] = -s2*c3
    m[2,1] = -c1*c2*s3 - s1*c3
    m[2,2] = -s1*c2*s3 + c1*c3
    m[2,3] = s2*s3
    m[3,1] = c1*s2
    m[3,2] = s1*s2
    m[3,3] = c2
    return m
end

function rates2dcm!(::Type{Val{323}}, m, s1, c1, s2, c2, s3, c3, rates)
    m[1,1] = -rates*s1*s2*s3
    m[1,2] = rates*c1*s2*s3
    m[2,1] = -rates*s1*s2*c3
    m[2,2] = rates*c1*s2*c3
    return m
end
