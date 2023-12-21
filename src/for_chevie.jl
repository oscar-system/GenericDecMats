# turn the list of integers and vectors into the decomposition matrix
# in the Chevie context
function _decomposition_matrix_from_list_Chevie(list::Vector, indets::Vector{String}, m::Int, n::Int)
    if length(indets) > 0
      vars = [Chevie.Mvp(Symbol(x)) for x in indets]
    else
      vars = Chevie.Mvp{Int, Int}[]
    end

    # Construct the decomposition matrix.
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
    list = Chevie.Mvp{Int,Int}.(list)
  # decmat = Matrix{Chevie.Mvp}(reshape(list, (m, n))')
  # decmat = Chevie.Mvp{Int,Int}.(reshape(list, (m, n))')
    return vars, reshape(list, (m, n))'
end

_decomposition_matrix_from_list[:Chevie] = _decomposition_matrix_from_list_Chevie

_labelled_matrix_formatted = labelled_matrix_formatted

function zero_repl_string(pol::Chevie.Mvp)
    io = IOBuffer()
    ioc = IOContext(io, :limit => true)
    show(ioc, pol)
    str = String(take!(io))
    return (str == "0" ? "." : str)
end
