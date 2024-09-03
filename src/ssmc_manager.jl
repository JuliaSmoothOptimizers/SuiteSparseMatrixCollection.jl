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
