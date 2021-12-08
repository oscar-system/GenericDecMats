mutable struct GenericDecompositionMatrix
    # parameters
    type::String
    n::Int
    d::Int
    # row and column labels
    ordinary::Vector{String}
    hc_series::Vector{String}
    # distribution of rows (ordinary) to blocks
    blocks::Vector{Tuple{String, String, Int}}
    blocklabels::Vector{Int}
    # dec. matrix and its entries
    R::Union{Oscar.MPolyRing{Oscar.fmpz}, Oscar.FlintIntegerRing}
    vars::Union{Vector{Oscar.fmpz_mpoly}, Vector{Oscar.fmpz}}
    decmat::Union{Oscar.Generic.MatSpaceElem{Oscar.fmpz_mpoly},Oscar.fmpz_mat}
    # exclude some values of q if necessary
    condition::String
    # bibliographical information
    origin::String
end

"""
    generic_decomposition_matrix(type::String, n::Int, d::Int)
    generic_decomposition_matrix(name::String)

Return the object described by the inputs if it is available,
and `nothing` otherwise.
"""
function generic_decomposition_matrix(type::String, n::Int, d::Int)
    return generic_decomposition_matrix(type*string(n)*"d"*string(d))
end

# load from file if available
function generic_decomposition_matrix(name::String)
    filename = _datadir*"/"*name*".json"
    isfile(filename) || return nothing
    str = read(filename, String)
    prs = JSON.parse(str; dicttype = Dict{Symbol,Any})

    if haskey(prs, :indets)
      R, vars = Oscar.PolynomialRing(Oscar.ZZ, Vector{String}(prs[:indets]))
    else
      R, vars = (Oscar.ZZ, Oscar.fmpz[])
    end

    # Construct the decomposition matrix.
    m = length(prs[:ordinary])
    n = length(prs[:hc_series])
    list = prs[:decmat]
    for i in 1:length(list)
      if isa(list[i], Vector)
        cfs = list[i][2:2:end]
        exp = Vector{Int64}[]
        for j in 1:2:(length(list[i])-1)
          monexp = zeros(Int64, length(vars))
          for k in 1:2:(length(list[i][j])-1)
            monexp[list[i][j][k]] = list[i][j][k+1]
          end
          push!(exp, monexp)
        end
        list[i] = R(cfs, exp)
      end
    end
    decmat = Oscar.matrix(R, m, n, list)

    # Extend the 'blocklabels' list by defect zero characters.
    diff = m - length(prs[:blocklabels])
    if 0 < diff
      mx = maximum(prs[:blocklabels])
      append!(prs[:blocklabels], (mx+1):(mx+diff) )
    end

    # Extend the 'blocks' list by defect zero blocks if necessary.
    nam = "$(prs[:type])$(prs[:n])"
    for i in (length(prs[:blocks])+1):maximum(prs[:blocklabels])
      push!(prs[:blocks],
            [nam, prs[:ordinary][findfirst(isequal(i), prs[:blocklabels])], 0])
    end

    obj = GenericDecompositionMatrix(
      prs[:type],
      prs[:n],
      prs[:d],
      prs[:ordinary],
      prs[:hc_series],
      [Tuple{String, String, Int}(x) for x in prs[:blocks]],
      prs[:blocklabels],
      R,
      vars,
      decmat,
      prs[:condition],
      prs[:origin],
    )
end

zero_repl_string(str::String) = (str == "0" ? "." : str)

function Base.show(io::IO, ::MIME"text/latex", decmat::GenericDecompositionMatrix)
  print(io, "\$")
  show(IOContext(io, :TeX => true), "text/plain", decmat)
  print(io, "\$")
end

function Base.show(io::IO, ::MIME"text/plain", decmat::GenericDecompositionMatrix)
    name = decmat.type*string(decmat.n)*", d = "*string(decmat.d)

    # Decide whether we want to restrict the output to one block.
    if haskey(io, :block)
      b = io[:block]
      name = name*" (block $b)"
      colindices = filter(j -> decmat.blocklabels[j] == b,
                          1:length(decmat.blocklabels))
      rowindices = filter(i -> ! iszero(decmat.decmat[i, colindices]),
                          1:length(decmat.ordinary))

      hc_series = decmat.hc_series[colindices]
      ordinary = decmat.ordinary[rowindices]
    else
      colindices = 1:length(decmat.blocklabels)
      rowindices = 1:length(decmat.ordinary)
      hc_series = decmat.hc_series
      ordinary = decmat.ordinary
    end

    # Create the IO context.
    ioc = IOContext(io,
      :header => [name, ""],
      :labels_col => hc_series,
      :separators_row => [0],
      :separators_col => [0],
      :labels_row => ordinary,
    )

    # Create strings from the matrix entries.
    strmat = [zero_repl_string(string(decmat.decmat[i,j]))
              for i in rowindices, j in colindices]

    # Print the labelled matrix.
    Oscar.labelled_matrix_formatted(ioc, strmat)
end
