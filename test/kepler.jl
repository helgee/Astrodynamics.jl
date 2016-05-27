@testset "Kepler" begin
    # Source: Vallado, Fundamentals of Astrodynamics and Applications, 4th edition, p. 94-95
    μ = 3.986004418e5
    r₀exp = [1131.340, -2282.343, 6672.423]
    v₀exp = [-5.64305, 4.30333, 2.42879]
    Δt = 40*60
    r₁exp = [-4219.7527, 4363.0292, -3958.7666]
    v₁exp = [3.689866, -1.916735, -6.112511]
    r₁, v₁ = kepler(μ, r₀exp, v₀exp, Δt)
    @test isapprox(r₁, r₁exp, rtol=1e-4)
    @test isapprox(v₁, v₁exp, rtol=1e-5)
    r₀, v₀ = kepler(μ, r₁, v₁, -Δt)
    @test r₀ ≈ r₀exp
    @test v₀ ≈ v₀exp
    r₁, v₁ = kepler(μ, r₀exp, v₀exp, eps())
    @test r₁ == r₀exp
    @test v₁ == v₀exp
    @test_throws ErrorException kepler(μ, r₀exp, v₀exp, Δt, 1)
end
