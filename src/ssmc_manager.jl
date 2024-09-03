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
    println("The artifact $(artifact_name) was not found on the disk.")
  else
    ssmc_nbytes = artifact_path(hash) |> totalsize
    remove_artifact(hash)
    println(
      "The artifact $(artifact_name) has been deleted, freeing up $(ssmc_nbytes |> format_bytes).",
    )
  end
end

"""
    delete_all_ssmc()

Remove all matrices from the SuiteSparseMatrixCollection.
"""
function delete_all_ssmc()
  hashes = Artifacts.extract_all_hashes(ssmc_artifacts, include_lazy = true)
  ssmc_nbytes = 0
  for hash in hashes
    if artifact_exists(hash)
      ssmc_nbytes += artifact_path(hash) |> totalsize
      remove_artifact(hash)
    end
  end
  if ssmc_nbytes == 0
    println(
      "No matrices to remove. All SSMC matrices from the SuiteSparseMatrixCollection have already been cleared.",
    )
  else
    println(
      "All matrices from the SuiteSparseMatrixCollection have been deleted for a total of $(ssmc_nbytes |> format_bytes).",
    )
  end
end

"""
    manage_ssmc(; sort_by::Symbol=:name, rev::Bool=false)

Opens a prompt allowing the user to selectively remove matrices from the SuiteSparseMatrixCollection.

By default, the matrices are sorted by name.
Alternatively, you can sort them by file size on disk by specifying `sort_by=:size`.
Use `rev=true` to reverse the sort order.
"""
function manage_ssmc(; sort_by::Symbol = :name, rev::Bool = false)
  # Get all installed ssmc matrices
  ssmc_hashes = SHA1[]
  ssmc_matrices = String[]
  ssmc_sizes = Int[]
  database = Artifacts.select_downloadable_artifacts(ssmc_artifacts, include_lazy = true)
  for ssmc_matrix in keys(database)
    ssmc_hash = SHA1(database[ssmc_matrix]["git-tree-sha1"])
    if artifact_exists(ssmc_hash)
      push!(ssmc_hashes, ssmc_hash)
      push!(ssmc_matrices, ssmc_matrix)
      ssmc_nbytes = artifact_path(ssmc_hash) |> totalsize
      push!(ssmc_sizes, ssmc_nbytes)
    end
  end

  if isempty(ssmc_matrices)
    println(
      "No matrices to remove. All SSMC matrices from the SuiteSparseMatrixCollection have already been cleared.",
    )
  else
    # Sort ssmc_problems and ssmc_sizes
    if sort_by === :name
      perm = sortperm(ssmc_matrices; rev)
    elseif sort_by == :size
      perm = sortperm(ssmc_sizes; rev)
    else
      error("unsupported sort value: :$sort_by (allowed: :name, :size)")
    end

    ssmc_hashes = ssmc_hashes[perm]
    ssmc_matrices = ssmc_matrices[perm]
    ssmc_sizes = ssmc_sizes[perm]

    # Build menu items
    menu_items = similar(ssmc_matrices)
    for i in eachindex(ssmc_matrices, ssmc_sizes)
      menu_items[i] = @sprintf("%-30s (%s)", ssmc_matrices[i], ssmc_sizes[i] |> Base.format_bytes)
    end

    # Prompt user
    ts = @sprintf("%s", sum(ssmc_sizes) |> Base.format_bytes)
    manage_ssmc_menu = TerminalMenus.request(
      "Which problems should be removed (total size on disk: $ts)?",
      TerminalMenus.MultiSelectMenu(menu_items; pagesize = 10, charset = :ascii),
    )

    # Handle no selection
    if isempty(manage_ssmc_menu)
      println("No matrices have been removed.")
    else
      # Otherwise prompt for confirmation
      println("\nThe following matrices have been marked for removal:\n")
      index_items = Int.(manage_ssmc_menu)
      for item in menu_items[sort(index_items)]
        println("  ", item)
      end
      print("\nAre you sure that these should be removed? [Y/n]: ")
      answer = strip(readline()) |> lowercase

      # If removal is confirmed, deleting the relevant files
      if isempty(answer) || answer == "yes" || answer == "y"
        for index_item in index_items
          ssmc_hash = ssmc_hashes[index_item]
          remove_artifact(ssmc_hash)
        end
        println("Removed ", length(manage_ssmc_menu), " matrices.")
      else
        println("Removed 0 matrices.")
      end
    end
  end
end

# Return total size on a disk of a file or directory
function totalsize(path::String)
  if !isdir(path)
    return filesize(path)
  end

  total = 0
  for (root, dirs, files) in walkdir(path)
    total += root |> filesize

    for file in files
      total += joinpath(root, file) |> filesize
    end
  end

  return total
end
