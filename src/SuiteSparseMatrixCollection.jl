module SuiteSparseMatrixCollection

using Pkg.Artifacts

using DataFrames
using JLD2
import REPL.TerminalMenus
import Base.format_bytes, Base.SHA1
import Printf.@sprintf

export ssmc_db, fetch_ssmc, ssmc_matrices, ssmc_formats, installed_ssmc
export delete_ssmc, delete_all_ssmc, manage_ssmc

const ssmc_jld2 = joinpath(@__DIR__, "ssmc.jld2")
const ssmc_artifacts = joinpath(@__DIR__, "..", "Artifacts.toml") |> normpath

"Formats in which matrices are available."
const ssmc_formats = ("MM", "RB")

include("ssmc_database.jl")
include("ssmc_manager.jl")

end
