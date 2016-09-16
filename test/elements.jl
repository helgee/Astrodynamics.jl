@testset "Elements" begin
    # Source: Vallado, Fundamentals of Astrodynamics and Applications, 4th edition, p. 94-95
    μ = 3.986004415e5
    rexp = [6524.834, 6862.875, 6448.296]
    vexp = [4.901327, 5.533756, 1.976341]
    elexp = [36127.343, 0.832853, 87.870, 227.898, 53.38, 92.355]
    elexp[3:end] = deg2rad.(elexp[3:end])
    el = keplerian(rexp, vexp, μ)
    @test isapprox(el, elexp, rtol=1e-3)
    r, v = cartesian(el, μ)
    @test r ≈ rexp
    @test v ≈ vexp
end
