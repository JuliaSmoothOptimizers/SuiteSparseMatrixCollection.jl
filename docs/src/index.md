# [SuiteSparseMatrixCollection.jl documentation](@id Home)

A straightforward interface to the [SuiteSparse Matrix Collection](https://sparse.tamu.edu/).

## How to install

```julia
pkg> add SuiteSparseMatrixCollection
pkg> test SuiteSparseMatrixCollection
```

## Examples

```julia
julia> using SuiteSparseMatrixCollection  # the database is named ssmc

julia> # name-based selection can be done with `ssmc_matrices()`
julia> ssmc_matrices("HB", "bcsstk")  # all matrices whose group contains "HB" and name contains "bcsstk"
julia> ssmc_matrices("", "bcsstk")    # all matrices whose name contains "bcsstk"
julia> ssmc_matrices("HB", "")        # all matrices whose group contains "HB"

julia> # select symmetric positive definite matrices with ≤ 100 rows and columns
julia> tiny = ssmc[(ssmc.numerical_symmetry .== 1) .& (ssmc.positive_definite.== true) .&
                   (ssmc.real .== true) .& (ssmc.nrows .≤ 100), :]

julia> # fetch the matrices selects in MatrixMarket format
julia> paths = fetch_ssmc(tiny, format="MM")  # matrices are downloaded in paths
```
