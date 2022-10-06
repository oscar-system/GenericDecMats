@testset "check that all matrices can be created and displayed" begin

    # Assume that there is something to test.
    context = collect(GenericDecMats._decomposition_matrix_from_list)[1][1]

    io = IOBuffer();
    for nam in GenericDecMats.generic_decomposition_matrices_names()
      Base.show(io, "text/plain", GenericDecMats.generic_decomposition_matrix(nam, context))
    end
    # When we arrive here without error then we are content,
    # provided there was something to check.
    @test length(String(take!(io))) > 0

end
