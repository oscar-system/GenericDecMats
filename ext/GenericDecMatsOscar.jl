module GenericDecMatsOscar

using GenericDecMats
isdefined(Base, :get_extension) ? (using Oscar) : (using ..Oscar)

# The following command would cause
# `Error requiring `Oscar` from `GenericDecMats`;
# fortunately, we do not need it.
#import Oscar: labelled_matrix_formatted

# turn the list of integers and vectors into the decomposition matrix
# in the Oscar context
function _decomposition_matrix_from_list_Oscar(list::Vector, indets::Vector{String}, m::Int, n::Int)
    if length(indets) > 0
      R, vars = Oscar.PolynomialRing(Oscar.ZZ, indets)
    else
      R, vars = (Oscar.ZZ, Oscar.ZZRingElem[])
    end

    # Construct the decomposition matrix.
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

    return vars, Oscar.matrix(R, m, n, list)
end

function __init__()
  GenericDecMats._decomposition_matrix_from_list[:Oscar] = _decomposition_matrix_from_list_Oscar
end
end
