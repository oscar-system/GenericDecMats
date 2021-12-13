@testset "check that all matrices can be created and displayed" begin

    io = IOBuffer();
    for nam in GenericDecMats.generic_decomposition_matrices_names()
      Base.show(io, "text/plain", generic_decomposition_matrix(nam))
    end
    # When we arrive here without error then we are content,
    # provided there was something to check.
    @test length(String(take!(io))) > 0

end
