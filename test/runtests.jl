using SuiteSparseMatrixCollection

using Test

function test_fetch()
  two_posdef = filter(p -> p.structure == "symmetric" && p.posDef == "yes" && p.type == "real" && p.rows ≤ 20, ssmc)
  @test length(two_posdef) == 2
  for format in SuiteSparseMatrixCollection.ssmc_formats
    fetch_ssmc(two_posdef, format=format)
    for matrix in two_posdef
      g_path = group_path(matrix, format=format)
      @test isdir(g_path)
      mtx_path = matrix_path(matrix, format=format)
      ext = format == "mat" ? "mat" : (format == "MM" ? "mtx" : "rb")
      if ext == "mat"
        @test isfile(joinpath(g_path, "$(matrix.name).$(ext)"))
      else
        @test isdir(mtx_path)
        @test isfile(joinpath(mtx_path, "$(matrix.name).$(ext)"))
      end
    end
  end
end

test_fetch()
