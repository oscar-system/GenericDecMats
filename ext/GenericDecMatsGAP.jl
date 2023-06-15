module GenericDecMatsGAP

using GenericDecMats
isdefined(Base, :get_extension) ? (using GAP) : (using ..GAP)

# GAPDoc is available, we can use it to turn the BibTeX references
# into text format references, which can be formatted at runtime.

const gdm_references = Dict{String, Any}()

function load_references()
  file = joinpath(@__DIR__, "..", "doc", "References.bib.xml")
  prs = GAP.Globals.ParseBibXMLextFiles(GAP.GapObj(file))::GAP.GapObj
  txt = GAP.julia_to_gap("Text")::GAP.GapObj
  for e in prs.entries
    r = GAP.Globals.RecBibXMLEntry(e, txt, prs.strings)::GAP.GapObj
    gdm_references[string(r.Label)] = e
  end
end

function formatted_reference(label::AbstractString)
  txt = GAP.julia_to_gap("Text")::GAP.GapObj
  Globals = GAP.Globals
  r = gdm_references[label]::GAP.GapObj
  origin = Globals.StringBibXMLEntry(r, txt)
  return string(Globals.Encode(Globals.Unicode(origin)::GAP.GapObj, Globals.GAPInfo.TermEncoding::GAP.GapObj)::GAP.GapObj)
end

function __init__()
  load_references()
end
end
