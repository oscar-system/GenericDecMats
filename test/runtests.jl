using Test

if ! (isdefined(Main, :Oscar) || isdefined(Main, :Gapjm))
  using Gapjm
  if ! isdefined(Main, :Gapjm)
    using Oscar
  end
end

if isdefined(Main, :Oscar) || isdefined(Main, :Gapjm)
  using GenericDecMats
  include("testdisp.jl")
end
