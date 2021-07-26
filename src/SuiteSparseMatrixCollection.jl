module SuiteSparseMatrixCollection

using Pkg.Artifacts

using DataFrames
using JLD2

export ssmc_db,
  fetch_ssmc, ssmc_matrices, ssmc, ssmc_formats, installed_ssmc, delete_ssmc, delete_all_ssmc

const ssmc_jld2 = joinpath(@__DIR__, "..", "src", "ssmc.jld2")
const ssmc_artifacts = joinpath(@__DIR__, "..", "Artifacts.toml")

function ssmc_db()
  file = jldopen(ssmc_jld2, "r")
  ssmc = file["df"]
  last_rev_date = file["last_rev_date"]
  close(file)
  @info "loaded database with revision date" last_rev_date
  return ssmc
end

"Formats in which matrices are available."
const ssmc_formats = ("MM", "RB")

"""
     fetch_ssmc(group::AbstractString, name::AbstractString; format="MM")

Download the matrix with name `name` in group `group`.
Return the path where the matrix is stored.
"""
function fetch_ssmc(group::AbstractString, name::AbstractString; format = "MM")
  group_and_name = group * "/" * name * "." * format
  # download lazy artifact if not already done and obtain path
  loc = ensure_artifact_installed(group_and_name, ssmc_artifacts)
  return joinpath(loc, name)
end

"""
     fetch_ssmc(matrices; format="MM")

Download matrices from the SuiteSparseMatrixCollection.
The argument `matrices` should be a `DataFrame` or `DataFrameRow`.
An array of strings is returned with the paths where the matrices are stored.
"""
function fetch_ssmc(matrices; format = "MM")
  format ∈ ssmc_formats || error("unknown format $format")
  paths = String[]
  for (group, name) ∈ zip(matrices.group, matrices.name)
    push!(paths, fetch_ssmc(group, name, format = format))
  end
  return paths
end

"""
    ssmc_matrices(ssmc, group, name)

Return a `DataFrame` of matrices whose group contains the string `group` and whose
name contains the string `name`.

    ssmc_matrices(ssmc, name)
    ssmc_matrices(ssmc, "", name)

Return a `DataFrame` of matrices whose name contains the string `name`.

    ssmc_matrices(ssmc, group, "")

Return a `DataFrame` of matrices whose group contains the string `group`.

Example: `ssmc_matrices(ssmc, "HB", "bcsstk")`.
"""
function ssmc_matrices(ssmc::DataFrame, group::AbstractString, name::AbstractString)
  ssmc[occursin.(group, ssmc.group) .& occursin.(name, ssmc.name), :]
end

ssmc_matrices(ssmc::DataFrame, name::AbstractString) = ssmc_matrices(ssmc, "", name)

"""
    installed_ssmc()

Return a vector of tuples `(group, name, format)` of all installed matrices from the SuiteSparseMatrixCollection.
"""
function installed_ssmc()
  database = Artifacts.select_downloadable_artifacts(ssmc_artifacts, include_lazy = true)
  installed_matrices = Tuple{String, String, String}[]
  for artifact_name in keys(database)
    hash = Base.SHA1(database[artifact_name]["git-tree-sha1"])
    if artifact_exists(hash)
      matrix = tuple(split(artifact_name, ['/', '.'])...)
      push!(installed_matrices, matrix)
    end
  end
  return installed_matrices
end

"""
    delete_ssmc(name::AbstractString, group::AbstractString, format = "MM")

Remove the matrix with name `name` in group `group` and format `format`.
"""
function delete_ssmc(group::AbstractString, name::AbstractString, format = "MM")
  artifact_name = group * "/" * name * "." * format

  meta = artifact_meta(artifact_name, ssmc_artifacts)
  (meta == nothing) && error("Cannot locate artifact $(artifact_name) in Artifacts.toml.")

  hash = Base.SHA1(meta["git-tree-sha1"])
  if !artifact_exists(hash)
    @info "The artifact $(artifact_name) was not found on the disk."
  else
    remove_artifact(hash)
    @info "The artifact $(artifact_name) has been deleted."
  end
end

"""
    delete_all_ssmc()

Remove all matrices from the SuiteSparseMatrixCollection.
"""
function delete_all_ssmc()
  hashes = Artifacts.extract_all_hashes(ssmc_artifacts, include_lazy = true)
  for hash in hashes
    remove_artifact(hash)
  end
  @info "All matrices from the SuiteSparseMatrixCollection have been deleted."
end

end
