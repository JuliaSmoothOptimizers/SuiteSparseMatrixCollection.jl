# SuiteSparseMatrixCollection.jl

[![Build Status](https://travis-ci.org/JuliaSmoothOptimizers/SolverBenchmark.jl.svg?branch=master)](https://travis-ci.org/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/s3213w0k9s9d45ro?svg=true)](https://ci.appveyor.com/project/dpo/suitesparsematrixcollection-jl)
[![](https://img.shields.io/badge/docs-latest-3f51b5.svg)](https://JuliaSmoothOptimizers.github.io/SuiteSparseMatrixCollection.jl/latest)
[![Coverage Status](https://coveralls.io/repos/github/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl?branch=master)

A straightforward interface to the [SuiteSparse Matrix Collection](https://sparse.tamu.edu/).

## How to install

```julia
julia> Pkg.clone("https://github.com/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl")
julia> Pkg.test("SuiteSparseMatrixCollection")
```

## Example

```julia
julia> using SuiteSparseMatrixCollection  # the database is named ssmc

julia> # fetch symmetric positive definite matrices with ≤ 100 rows and columns
julia> tiny = filter(p -> p.structure == "symmetric" && p.posDef == "yes" && p.type == "real" && p.rows ≤ 100, ssmc)
julia> fetch_ssmc(tiny, format="MM")  # download in MatrixMarket format

julia> for matrix in tiny
         println(matrix_path(matrix, format="MM"))  # matrices are stored here
       end
```
