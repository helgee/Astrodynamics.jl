@testset "Parameters" begin
    @test_throws ArgumentError Parameter(1, 1)
    @test_throws ArgumentError Parameter(2, 1)
    @test_throws ArgumentError Parameter(0, 1, 2)
    p = Parameter(0)
    @test lower(p) == -Inf
    @test upper(p) == Inf
    @test isparameter(p) == true
    c = constant(1)
    @test isparameter(c) == false
    push!(p, 1)
    @test p == 1
    reset!(p)
    @test p == 0
    arr = [p, 1.0]
    @test typeof(arr) == ParameterArray
    @test isparameter(arr) == [true, false]
    @test values(arr) == [0.0, 1.0]
    @test getparameters(p) == [p]
    @test getparameters(c) == Parameter[]
    @test getparameters(arr) == [p]
    @test arr+3 == [3.0, 4.0]
    @test 3+arr == [3.0, 4.0]
    @test arr-3 == [-3.0, -2.0]
    @test 3-arr == [3.0, 2.0]
    @test arr*3 == [0.0, 3.0]
    @test 3*arr == [0.0, 3.0]
    @test arr/3 == [0.0, 1/3.0]
    @test p < c
    @test c > p
    @test 3/p == Inf
    const fun = (
        :abs2, :acosh, :acot, :acotd, :acoth, :acsc, :acscd, :acsch, :airy, :airyai,
        :airyaiprime, :airybi, :airybiprime, :airyprime, :asec, :asecd, :asinh,
        :atan, :atand, :besselj0, :besselj1, :bessely0, :bessely1, :cbrt, :cos, :cosd, :cosh,
        :cot, :cotd, :coth, :csc, :cscd, :csch, :digamma, :erf, :erfc, :erfi, :exp, :exp2, :expm1, :gamma,
        :inv, :lgamma, :log, :log10, :log1p, :log2, :sec, :secd, :sech, :sin, :sind, :sinh, :sqrt, :tan,
        :tand, :tanh, :trigamma,
    )
    const fun2 = (:acos, :acosd, :asech, :asin, :asind, :atanh)
    val = pi/2
    push!(p, val)
    for f in fun
        @eval begin
            @test $f($p) == $f(float($val))
        end
    end
    val = 0.0
    push!(p, val)
    for f in fun2
        @eval begin
            @test $f($p) == $f(float($val))
        end
    end
end
