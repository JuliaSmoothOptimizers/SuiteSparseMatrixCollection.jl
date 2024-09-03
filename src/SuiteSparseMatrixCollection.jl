module SuiteSparseMatrixCollection

using Pkg.Artifacts

using DataFrames
using JLD2

export ssmc_db,
  fetch_ssmc, ssmc_matrices, ssmc_formats, installed_ssmc, delete_ssmc, delete_all_ssmc

const ssmc_jld2 = joinpath(@__DIR__, "..", "src", "ssmc.jld2")
const ssmc_artifacts = joinpath(@__DIR__, "..", "Artifacts.toml")

"Formats in which matrices are available."
const ssmc_formats = ("MM", "RB")

include("ssmc_database.jl")
include("ssmc_manager.jl")

end
