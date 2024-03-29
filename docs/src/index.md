# [SuiteSparseMatrixCollection.jl documentation](@id Home)

A straightforward interface to the [SuiteSparse Matrix Collection](https://sparse.tamu.edu/).

## How to install

```julia
pkg> add SuiteSparseMatrixCollection
pkg> test SuiteSparseMatrixCollection
```

## Examples

```julia
julia> using SuiteSparseMatrixCollection

julia> # name-based selection can be done with `ssmc_matrices()`
julia> ssmc = ssmc_db()                     # the database is named ssmc
julia> ssmc_matrices(ssmc, "HB", "bcsstk")  # all matrices whose group contains "HB" and name contains "bcsstk"
julia> ssmc_matrices(ssmc, "", "bcsstk")    # all matrices whose name contains "bcsstk"
julia> ssmc_matrices(ssmc, "HB", "")        # all matrices whose group contains "HB"

julia> # select symmetric positive definite matrices with ≤ 100 rows and columns
julia> tiny = ssmc[(ssmc.numerical_symmetry .== 1) .& (ssmc.positive_definite.== true) .&
                   (ssmc.real .== true) .& (ssmc.nrows .≤ 100), :]

julia> # fetch the matrices selects in MatrixMarket format
julia> paths = fetch_ssmc(tiny, format="MM")   # matrices are downloaded in paths
julia> downloaded_matrices = installed_ssmc()  # name of all downloaded matrices
julia> delete_ssmc("HB", "bcsstk02")           # delete the matrix "bcsstk02" of group "HB"
julia> delete_all_ssmc()                       # delete all matrices from the SuiteSparseMatrixCollection
```
