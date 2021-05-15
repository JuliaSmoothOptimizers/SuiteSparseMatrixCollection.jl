using Pkg.Artifacts

using ArtifactUtils
using DataFrames
using JLD2

const ssmc_url = "https://sparse.tamu.edu"
const ssmc_jld2 = joinpath(@__DIR__, "..", "src", "ssmc.jld2")
db = jldopen(ssmc_jld2, "r")
matrices = db["df"]

# mat files are not recognized as artifacts
formats = ("MM", "RB")
nmatrices = size(matrices, 1) * length(formats)
const artifacts_toml = joinpath(@__DIR__, "..", "Artifacts.toml")

global k = 0
fails = String[]
for format ∈ formats
  global k
  for matrix ∈ eachrow(matrices)
    k += 1
    url = "$ssmc_url/$format/$(matrix.group)/$(matrix.name).tar.gz"
    println("$k/$nmatrices: ", url)
    try
      add_artifact!(
        artifacts_toml,
        "$(matrix.group)/$(matrix.name).$(format)",
        url,
        lazy = true,
        force = true,
      )
    catch
      push!(fails, matrix.name)
    end
  end
end
length(fails) > 0 && @warn "the following matrices could not be downloaded" fails
