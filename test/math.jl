@testset "Math" begin
    @testset "Newton" begin
        @test newton(1.5, x -> 1-2/x^2, x -> 4/x^3) ≈ √2
        @test_throws ErrorException newton(1.5, x -> 1-2/x^2, x -> 4/x^3, 1)
    end
    @testset "Rotations" begin
        @test rotate_x(2π) ≈ eye(3)
        @test rotate_y(2π) ≈ eye(3)
        @test rotate_z(2π) ≈ eye(3)
        ex = [1.0; 0.0; 0.0]
        ey = [0.0; 1.0; 0.0]
        @test rotate_x(π/2)*ey ≈ [0.0; 0.0; 1.0]
        @test rotate_y(π/2)*ex ≈ [0.0; 0.0; 1.0]
        @test rotate_z(π/2)*ex ≈ [0.0; 1.0; 0.0]
    end
end
