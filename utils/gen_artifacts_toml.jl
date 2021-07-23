using Pkg.Artifacts

using ArtifactUtils
using DataFrames
using JLD2

const ssmc_url = "https://sparse.tamu.edu"
const ssmc_jld2 = joinpath(@__DIR__, "..", "src", "ssmc.jld2")
db = jldopen(ssmc_jld2, "r")
matrices = db["df"]

formats = ("MM", "RB", "mat")
nmatrices = size(matrices, 1) * length(formats)
const artifacts_toml = joinpath(@__DIR__, "..", "Artifacts.toml")

global k = 0
fails = String[]
for format ∈ formats
  global k
  for matrix ∈ eachrow(matrices)
    k += 1
    if format == "mat"
      sscm_file = "$(matrix.name).mat"
      url = "$ssmc_url/$format/$(matrix.group)/$sscm_file"
    else
      sscm_file = "$(matrix.name).tar.gz"
      url = "$ssmc_url/$format/$(matrix.group)/$sscm_file"
    end
    println("$k/$nmatrices: ", url)
    try
      problem_hash = artifact_hash("$(matrix.group)/$(matrix.name).$(format)", artifacts_toml)
      if problem_hash === nothing || !artifact_exists(problem_hash)
        problem_hash = create_artifact() do artifact_dir
          download("$url", joinpath(artifact_dir, sscm_file))
        end

        path_artifact = artifact_path(problem_hash)
        hash_artifact = ArtifactUtils.sha256sum("$path_artifact/$sscm_file")
        remove_artifact(problem_hash)

        bind_artifact!(
          artifacts_toml,
          "$(matrix.group)/$(matrix.name).$(format)",
          problem_hash,
          download_info = [(url, hash_artifact)],
          lazy = true,
          force = true,
        )
      end
    catch
      push!(fails, matrix.name)
    end
  end
end
length(fails) > 0 && @warn "the following matrices could not be downloaded" fails
