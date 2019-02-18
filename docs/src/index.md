# [SuiteSparseMatrixCollection.jl documentation](@id Home)

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
