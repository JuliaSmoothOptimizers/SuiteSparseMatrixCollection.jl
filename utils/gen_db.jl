# run this script to update the database
# please open a pull request at
# https://github.com/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl/pulls

using DataFrames
using Dates
using JLD2
using MAT

const colnames = Dict(
  "Group" => "group",
  "nnzdiag" => "nnzdiag",
  "nrows" => "nrows",
  "numerical_symmetry" => "numerical_symmetry",
  "amd_vnz" => "amd_vnz",
  "isBinary" => "binary",
  "sprank" => "structural_rank",
  "isND" => "is_nd",
  "isGraph" => "is_graph",
  "RBtype" => "RB_type",
  "lowerbandwidth" => "lower_bandwidth",
  "nzero" => "explicit_zeros",
  "amd_flops" => "amd_flops",
  "xmin" => "xmin",
  "posdef" => "positive_definite",
  "ncc" => "connected_components",
  "Name" => "name",
  "amd_rnz" => "amd_rnz",
  "nentries" => "pattern_entries",
  "ncols" => "ncols",
  "rcm_lowerbandwidth" => "rcm_lower_bandwidth",
  "amd_lnz" => "amd_lnz",
  "nnz" => "nnz",
  "pattern_symmetry" => "pattern_symmetry",
  "rcm_upperbandwidth" => "rcm_upper_bandwidth",
  "upperbandwidth" => "upper_bandwidth",
  "cholcand" => "cholesky_candidate",
  "xmax" => "xmax",
  "isReal" => "real",
  "nblocks" => "nblocks",
)

const coltypes = Dict(
  "group" => String,
  "nnzdiag" => Int,
  "nrows" => Int,
  "numerical_symmetry" => Float64,
  "amd_vnz" => Int,
  "binary" => Bool,
  "structural_rank" => Int,
  "is_nd" => Bool,
  "is_graph" => Bool,
  "RB_type" => String,
  "lower_bandwidth" => Int,
  "explicit_zeros" => Int,
  "amd_flops" => Float64,
  "xmin" => Complex{Float64},
  "positive_definite" => Bool,
  "connected_components" => Int,
  "name" => String,
  "amd_rnz" => Int,
  "pattern_entries" => Int,
  "ncols" => Int,
  "rcm_lower_bandwidth" => Int,
  "amd_lnz" => Int,
  "nnz" => Int,
  "pattern_symmetry" => Float64,
  "rcm_upper_bandwidth" => Int,
  "upper_bandwidth" => Int,
  "cholesky_candidate" => Bool,
  "xmax" => Complex{Float64},
  "real" => Bool,
  "nblocks" => Int,
)

const ssmc_url = "https://sparse.tamu.edu"
const ssmc_mat = "ss_index.mat"
const ssmc_db = joinpath(@__DIR__, ssmc_mat)
const mat_url = "http://sparse.tamu.edu/files/$ssmc_mat"
try
  @info "attempting to download updated SuiteSparse database"
  download(mat_url, ssmc_db)
catch e
  @error e
  error("unable to download SuiteSparse database")
end

matdata = matread(ssmc_db)
ss_index = matdata["ss_index"]

download_time = ss_index["DownloadTimeStamp"]
last_rev_date = ss_index["LastRevisionDate"]

ssmc_jld2 = joinpath(@__DIR__, "..", "src", "ssmc.jld2")
update = false
const dfmt = DateFormat("dd-uuu-yyyy HH:MM:SS")
last_rev = DateTime(last_rev_date, dfmt)
if isfile(ssmc_jld2)
  file = jldopen(ssmc_jld2, "r")
  last_rev_date_on_file = file["last_rev_date"]
  close(file)
  last_rev_on_file = DateTime(last_rev_date_on_file, dfmt)
  update = last_rev > last_rev_on_file
else
  update = true
end

function to_vec(x, T)
  nd = ndims(x)
  nd > 2 && error("too many dims!")
  nd == 1 && (return x)
  y = T[]
  for val ∈ x
    push!(y, val)
  end
  return y
end

if update
  @info "updating database to revision of" last_rev
  df = DataFrame()
  for (k, v) ∈ ss_index
    k ∈ ("DownloadTimeStamp", "LastRevisionDate") && continue
    colname = colnames[k]
    setproperty!(df, colname, to_vec(v, coltypes[colname]))
  end
  df = df[
    !,
    [
      :group,
      :name,
      :nrows,
      :ncols,
      :nnz,
      :structural_rank,
      :numerical_symmetry,
      :positive_definite,
      :pattern_symmetry,
      :binary,
      :real,
      :nnzdiag,
      :xmin,
      :xmax,
      :lower_bandwidth,
      :upper_bandwidth,
      :rcm_lower_bandwidth,
      :rcm_upper_bandwidth,
      :amd_vnz,
      :amd_lnz,
      :amd_rnz,
      :explicit_zeros,
      :pattern_entries,
      :cholesky_candidate,
      :connected_components,
      :nblocks,
      :amd_flops,
      :RB_type,
      :is_graph,
      :is_nd,
    ],
  ]

  jldopen(ssmc_jld2, "w") do file
    file["df"] = df
    file["last_rev_date"] = last_rev_date
    file["download_time"] = download_time
  end
  @info "please open a pull request at https://github.com/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl/pulls"
else
  @info "database is already up to date"
end
