using SuiteSparseMatrixCollection

using Test

function test_fetch()
  two_posdef = filter(p -> p.structure == "symmetric" && p.posDef == "yes" && p.type == "real" && p.rows ≤ 20, ssmc)
  @test length(two_posdef) == 2
  for format in SuiteSparseMatrixCollection.ssmc_formats
    fetch_ssmc(two_posdef, format=format)
    for matrix in two_posdef
      mtx_path = matrix_path(matrix, format=format)
      @test isdir(mtx_path)
      ext = format == "mat" ? "mat" : "tar.gz"
      @test isfile(joinpath(mtx_path, "$(matrix.name).$(ext)"))
    end
  end
end

test_fetch()
