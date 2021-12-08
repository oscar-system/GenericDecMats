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
    vars::Vector{Gapjm.Mvp}
    decmat::Matrix{Gapjm.Mvp}
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
      vars = [Gapjm.Mvp(Symbol(x)) for x in prs[:indets]]
    else
      vars = Gapjm.Mvp[]
    end

    m = length(prs[:ordinary])
    n = length(prs[:hc_series])
    list = prs[:decmat]
    for i in 1:length(list)
      if isa(list[i], Vector)
        val = 0
        l = list[i]
        for j in 1:2:(length(l)-1)
          mon = 1
          for k in 1:2:length(l[j])
            mon = mon*vars[l[j][k]]^l[j][k+1]
          end
          val = val + l[j+1]*mon
        end
        list[i] = val
      end
    end
    decmat = Matrix{Gapjm.Mvp}(reshape(list, (m, n))')

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
      vars,
      decmat,
      prs[:condition],
      prs[:origin],
    )
end

function zero_repl_string(pol::Gapjm.Mvp)
    io = IOBuffer()
    ioc = IOContext(io, :limit => true)
    show(ioc, pol)
    str = String(take!(io))
    return (str == "0" ? "." : str)
end

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
      :limit => true,
    )

    # Create strings from the matrix entries.
    strmat = [zero_repl_string(decmat.decmat[i,j])
              for i in rowindices, j in colindices]

    # Print the labelled matrix.
    labelled_matrix_formatted(ioc, strmat)
end
