@testset "Math" begin
    @testset "Newton" begin
        @test newton(1.5, x -> 1-2/x^2, x -> 4/x^3) ≈ √2
        @test_throws ErrorException newton(1.5, x -> 1-2/x^2, x -> 4/x^3, 1)
    end
    @test cross([1.0, 2.0, 3.0], [4.0, 5.0, 6.0]) == cross_matrix([1.0, 2.0, 3.0])*[4.0, 5.0, 6.0]
end
