##############################################################################
##
#F  MatrixFromRecipe( <recipe>[, <mat>] )
##
##  Return the block diagonal matrix described by <recipe>.
##
MatrixFromRecipe:= function( recipe, mat... )
    local blockdims, n, result, ind, i, entry, bl, fun, endpos;

    blockdims:= List( recipe,
                      entry -> Sum( entry{ [ 2 .. Length( entry ) ] } ) );
    n:= Sum( blockdims );
    result:= IdentityMat( n );
    ind:= 0;
    for i in [ 1 .. Length( recipe ) ] do
      entry:= recipe[i];
      if entry[1] = "Sub" and Length( mat ) = 1 then
        bl:= [ ind+1 .. ind + entry[2] ];
        result{ bl }{ bl }:= mat[1]{ bl }{ bl };
      elif entry[1] <> "Id" then
        fun:= ValueGlobal( entry[1] );
        endpos:= ind + blockdims[i];
        result{ [ ind+1 .. endpos ] }{ [ ind+1 .. endpos ] }:=
            CallFuncList( fun, entry{ [ 2 .. Length( entry ) ] } );
      fi;
      ind:= ind + blockdims[i];
    od;

    return result;
end;


##############################################################################
##
#F  GDM_name_info( <name>
##
GDM_name_info:= function( name )
    local pos, pos2, type, n, d;

    pos:= Position( name, 'd' );
    pos2:= pos - 1;
    while IsDigitChar( name[ pos2 ] ) do
      pos2:= pos2 - 1;
    od;
    type:= name{ [ 1 .. pos2 ] };
    n:= Int( name{ [ pos2 + 1 ..pos - 1 ] } );
    d:= Int( name{ [ pos + 1 .. Length( name ) ] } );
    return [ type, n, d ];
end;


##############################################################################
##
#F  GDM_polynomial_from_extrep( <fam>, <entry>, <indetsindices> )
##
GDM_polynomial_from_extrep:= function( fam, entry, indetsindices )
    local i, monom, j;

    for i in [ 1, 3 .. Length( entry ) - 1 ] do
      monom:= entry[i];
      for j in [ 1, 3 .. Length( monom ) - 1 ] do
        monom[j]:= indetsindices[ monom[j] ];
      od;
    od;
    return PolynomialByExtRep( fam, entry );
end;


##############################################################################
##
#F  GDM_string_from_polynomial( <pol> )
##
##  Return a LaTeX string describing the multivariate polynomial <pol>.
##
GDM_string_from_polynomial:= function( pol )
    local extrep, nams, i, pos, l, stri, li, j, res;

    extrep:= ExtRepPolynomialRatFun( pol );
    if Length( extrep ) = 0 then
      return "0";
    fi;

    nams:= ShallowCopy( FamilyObj( pol )!.namesIndets );
    for i in [ 1 .. Length( nams ) ] do
      if IsBound( nams[i] ) then
        pos:= PositionProperty( nams[i], IsDigitChar );
        if pos <> fail then
          nams[i]:= Concatenation( nams[i]{ [ 1 .. pos-1 ]}, "_{",
                        nams[i]{ [ pos .. Length( nams[i] ) ] }, "}" );
        fi;
      fi;
    od;

    l:= [];
    for i in [ 2, 4 .. Length( extrep ) ] do
      li:= extrep[ i-1 ];
      if extrep[i] = 1 and Length( li ) > 0 then
        stri:= "";
      elif extrep[i] = -1 and Length( li ) > 0 then
        stri:= "-";
      else
        stri:= ShallowCopy( String( extrep[i] ) );
      fi;
      if Length( li ) <> 0 then
        for j in [ 2, 4 .. Length( li ) ] do
          Append( stri, nams[ li[j-1] ] );
          if li[j] <> 1 then
            Append( stri, "^{" );
            Append( stri, String( li[j] ) );
            Append( stri, "}" );
          fi;
        od;
      fi;
      Add( l, stri );
    od;
    l:= Reversed( l );
    res:= l[1];
    for i in [ 2 .. Length( l ) ] do
      if l[i][1] <> '-' then
        Add( res, '+' );
      fi;
      Append( res, l[i] );
    od;
    return res;
end;


##############################################################################
##
#F  GDM_ConditionString( <condition>, <format> )
##
##  <format> must be one of '"LaTeX"', '"Text"'.
##
GDM_ConditionString:= function( condition, format )
    local condstrings, entry, str, pos;

    condstrings:= [];
    if condition <> "none" then
      for entry in List( SplitString( condition, "," ),
                         NormalizedWhitespace ) do
        str:= "";
        if StartsWith( entry, "ell>" ) then
          Append( str, "l > " );
          Append( str, entry{ [ 5 .. Length( entry ) ] } );
          Add( condstrings, str );
        elif StartsWith( entry, "(q" ) then
          # expect '(q^i+...)_ell>k'
          pos:= PositionSublist( entry, ")_ell>" );
          if pos = fail then
            return fail;
          fi;
          Append( str, entry{ [ 1 .. pos+1 ] } );
          Append( str, "l > " );
          Append( str, entry{ [ pos + 6 .. Length( entry ) ] } );
          Add( condstrings, str );
        else
          return fail;
        fi;
      od;
    fi;

    if format = "LaTeX" then
      condstrings:= List( condstrings, x -> Concatenation( "$", x, "$" ) );
    fi;

    return JoinStringsWithSeparator( condstrings, ", " );
end;


##############################################################################
##
#F  GDM_GAP_record_from_raw_data( <scan> )
##
##  For a record <scan> obtained from evaluating a JSON text encoding a
##  generic decomposition matrix, set additional components in <scan>
##  and then return <scan>.
##
GDM_GAP_record_from_raw_data:= function( scan )
    local nam, indets, fam, indetsindices, i, m, n, diff;

    # Insert 'name' and 'vars'.
    scan.name:= [ scan.type, scan.n ];
    scan.vars:= rec();

    # Prepare the indeterminates.
    if IsBound( scan.indets ) and Length( scan.indets ) > 0 then
      for nam in scan.indets do
        scan.vars.( nam ):= Indeterminate( Integers, nam );
      od;

      indets:= List( scan.indets, nam -> Indeterminate( Integers, nam ) );
      fam:= FamilyObj( indets[1] );
      indetsindices:= List( scan.indets,
                            nam -> Position( fam!.namesIndets, nam ) );
    fi;

    # Construct the decomposition matrix.
    for i in [ 1 .. Length( scan.decmat ) ] do
      if not IsInt( scan.decmat[i] ) then
        scan.decmat[i]:= GDM_polynomial_from_extrep( fam, scan.decmat[i],
                             indetsindices );
      fi;
    od;
    if scan.decmat <> [] then
      m:= Length( scan.ordinary );
      n:= Length( scan.hc_series );
      scan.decmat:= List( [ 1 .. m ],
                          i -> scan.decmat{ [ (i-1)*n+1 .. i*n ] } );
    fi;

    # Extend the 'blocklabels' list by defect zero characters.
    diff:= Length( scan.ordinary ) - Length( scan.blocklabels );
    if 0 < diff then
      Append( scan.blocklabels, Maximum( scan.blocklabels ) + [ 1 .. diff ] );
    fi;

    # Extend the 'blocks' list by defect zero blocks if necessary.
    if scan.n < 10 then
      nam:= Concatenation( scan.type, "_", String( scan.n ) );
    else
      nam:= Concatenation( scan.type, "_{", String( scan.n ), "}" );
    fi;
    for i in [ Length( scan.blocks ) + 1 .. Maximum( scan.blocklabels ) ] do
      Add( scan.blocks,
           [ nam, scan.ordinary[ Position( scan.blocklabels, i ) ], 0 ] );
    od;

    return scan;
end;


##############################################################################
##
#F  GDM_RawData( <name> )
##
##  Return the GAP record obtained by evaluating the contents of the
##  data file for <name> with 'JsonStringToGap'.
##
GDM_RawData:= function( name )
    local file;

    file:= Filename( GDM_pkgdir, Concatenation( "data/", name, ".json" ) );
    if not IsReadableFile( file ) then
      return fail;
    fi;

    return JsonStringToGap( StringFile( file ) );
end;


##############################################################################
##
#F  GDM_TestConsistency( <name> )
##
##  Test both the data file and the object in the GAP session.
##
##  - Test the existence of mandatory components.
##  - Test the consistency of matrices and their labels.
##  - Test the consistency of block information.
##
GDM_TestConsistency:= function( name )
    local raw, record, cmps, miss, lr, lc, m, nam, bpos, blpos, row, onepos;

    # create a record with raw data
    raw:= GDM_RawData( name );
    if raw = fail then
      return fail;
    fi;

    # create the data record, as an independent object
    record:= GDM_GAP_record_from_raw_data( StructuralCopy( raw ) );

    # missing mandatory components?
    cmps:= [ "condition", "d", "decmat", "hc_series", "name", "ordinary",
             "origin" ];
    miss:= Filtered( cmps, c -> not IsBound( record.( c ) ) );
    if not IsEmpty( miss ) then
      return Concatenation( "missing components: ", String( miss ) );
    fi;

    # consistency of lengths
    lr:= Length( raw.ordinary );
    lc:= Length( raw.hc_series );
    m:= record.decmat;
    if Length( m ) = 0 then
      return "empty 'decmat'";
    elif Length( m ) <> lr then
      return "inconsistent 'decmat' and 'ordinary'";
    elif ForAny( m, a -> Length( a ) <> lc ) then
      return "inconsistent 'decmat' and 'hc_series'";
    fi;

    # consistency of block information
    if IsBound( record.blocklabels ) and
         Length( record.blocklabels ) <> lr then
      return "inconsistent 'decmat' and 'blocklabels'";
    elif IsBound( record.blocklabels ) and
         IsBound( record.blocks ) and
         MaximumList( record.blocklabels, 0 ) <> Length( record.blocks ) then
      return "inconsistent 'blocks' and 'blocklabels'";
    fi;

    # necessary conditions for defect zero blocks
    # - the first entry in a defect zero block must be the current type,
    # - the position of a defect zero block in 'blocks' occurs exactly once
    #   in 'blocklabels',
    # - the corresponding label in 'ordinary' is equal to the 2nd entry in
    #   the triple in 'blocks',
    # - the corresponding row in 'decmat' contains exactly one nonzero entry
    #   (equal to 1), and its column has exactly one nonzero entry.
    if record.n < 10 then
      nam:= Concatenation( record.type, "_", String( record.n ) );
    else
      nam:= Concatenation( record.type, "_{", String( record.n ), "}" );
    fi;
    for bpos in PositionsProperty( record.blocks, l -> l[3] = 0 ) do
      if record.blocks[ bpos ][1] <> nam then
        return Concatenation( "defect zero block '", String( bpos ),
                   "' has strange label" );
      fi;
      blpos:= Positions( record.blocklabels, bpos );
      if Length( blpos ) <> 1 then
        return Concatenation( "defect zero block '", String( bpos ),
                   "' does not occur exactly once in 'blocklabels'" );
      elif record.blocks[ bpos ][2] <> record.ordinary[ blpos[1] ] then
        return Concatenation( "defect zero block '", String( bpos ),
                   "' has strange label of ordinary character" );
      fi;
      row:= record.decmat[ blpos[1] ];
      onepos:= Positions( row, 1 );
      if Length( onepos ) <> 1 then
        return Concatenation( "defect zero block '", String( bpos ),
                   "' has more than one 1 in 'decmat'" );
      elif Number( row, IsZero ) <> lr - 1 then
        return Concatenation( "defect zero block '", String( bpos ),
                   "' has not enough zeros in 'decmat'" );
      elif Number( record.decmat, r -> r[ onepos[1] ] = 0 ) <> lc - 1 then
        return Concatenation( "defect zero block '", String( bpos ),
                   "' does not fit to column '",
                   String( onepos[1] ), "' in 'decmat'" );
      fi;
    od;

    # Check that the 'recipe' field, if available, is correct.
    if IsBound( record.recipe ) and
       MatrixFromRecipe( record.recipe, record.decmat ) <> record.decmat then
      return "'recipe' is not correct";
    fi;

    return "";
end;


##############################################################################
##
#F  BrauerStem( <n1>, <n2>, ... )
##
##  returns a block diagonal matrix of dimension <n1> + <n2> + ...
##  whose i-th diagonal block is an <ni> times <ni> matrix whose nonzero
##  entries are all 1 and occur on the main diagonal and on the first
##  diagonal below it.
##
BrauerStem:= function( arg )
    local res, ind, i, j;

    res:= IdentityMat( Sum( arg ) );
    ind:= 0;
    for i in arg do
      for j in [ 2 .. i ] do
        res[ ind+j, ind+j-1]:= 1;
      od;
      ind:= ind+i;
    od;
    return res;
end;


##############################################################################
##
#F  GenericDecompositionMatrix( <name> )
#F  GenericDecompositionMatrix( <type>, <n>, <d> )
##
GenericDecompositionMatrix:= function( arg )
    local name, r;

    if Length( arg ) = 1 and IsString( arg[1] ) then
      name:= arg[1];
    elif Length( arg ) = 3 and IsString( arg[1] )
         and IsPosInt( arg[2] ) and IsPosInt( arg[3] ) then
      name:= Concatenation( arg[1], String( arg[2] ), "d", String( arg[3] ) );
    else
      Error( "usage: GenericDecompositionMatrix( <name> ) or\n",
             "GenericDecompositionMatrix( <type>, <n>, <d> )" );
    fi;

    r:= GDM_RawData( name );
    if r = fail then
      return fail;
    fi;

    return GDM_GAP_record_from_raw_data( r );
end;


##############################################################################
##
#F  GenericDecompositionMatricesNames()
##
GenericDecompositionMatricesNames:= function()
    local dir, files;

    dir:= Filename( GDM_pkgdir, "data" );

    files:= Filtered( DirectoryContents( dir ), x -> EndsWith( x, ".json" ) );
    files:= List( files, x -> x{ [ 1 .. Position( x, '.' ) - 1 ] } );
    SortParallel( List( files, GDM_name_info ), files );
    return files;
end;


##############################################################################
##
#F  GenericDecompositionMatricesShowOverview()
##
GenericDecompositionMatricesShowOverview:= function()
    local names, max, ncols, i, name;

    names:= GenericDecompositionMatricesNames();
    max:= Maximum( List( names, Length ) ) + 1;
    ncols:= Int( ( SizeScreen()[1] - 4 ) / max );
    i:= 0;
    Print( "  " );
    for name in names do
      Print( String( name, max ) );
      i:= i + 1;
      if i = ncols then
        Print( "\n  " );
        i:= 0;
      fi;
    od;
end;


##############################################################################
##
#V  GDM_References
#F  GDM_Load_References()
##
##  Load the references into the record 'GDM_References'.
##  They are currently used by the 'Browse' function.
##
GDM_References:= rec();
GDM_Load_References:= function()
    local prs, e, r;

    prs:= ParseBibXMLextFiles(
              Filename( GDM_pkgdir, "doc/References.bib.xml" ) );
    for e in prs.entries do
      r:= RecBibXMLEntry( e, "Text", prs.strings );
      GDM_References.( r.Label ):= e;
    od;
end;
GDM_Load_References();


##############################################################################
##
#F  Browse( <decmat>[, <blocknr>] )
##
InstallMethod( Browse, [ "IsRecord" ],
    function( r )
    local origin, cond;

    if not IsBound( r.decmat ) then
      TryNextMethod();
    fi;

    origin:= List( SplitString( r.origin, "," ),
                   x -> StringBibXMLEntry( GDM_References.( x ), "Text" ) );
#TODO: As soon as Browse supports unicode characters, do not convert to ASCII.
    origin:= Encode( SimplifiedUnicodeString(
                         Unicode( Concatenation( origin ) ), "ASCII" ),
                     "ASCII" );

    cond:= GDM_ConditionString( r.condition, "Text" );
    if cond = fail then
      cond:= "";
    elif cond <> "" then
      cond:= Concatenation( "  (", cond, ")" );
    fi;

    NCurses.BrowseDenseList( r.decmat, rec(
        header:= [ Concatenation( r.name[1], String( r.name[2] ),
                       "(q), d = ", String( r.d ), cond ),
                   "" ],
        convertEntry:= NCurses.ReplaceZeroByDot,
        labelsCol:= [ r.hc_series ],
        labelsRow:= List( r.ordinary, x -> [ x ] ),
        footer:= Concatenation( [ "\n" ], SplitString( origin, "\n" ) ),
      ) );
    end );

InstallOtherMethod( Browse, [ "IsRecord", "IsInt" ],
    function( r, i )
    local pos, tr, poss, defect;

    if not IsBound( r.decmat ) then
      TryNextMethod();
    fi;
    pos:= Positions( r.blocklabels, i );
    tr:= TransposedMat( r.decmat{ pos } );
    poss:= Filtered( [ 1 .. Length( tr ) ], j -> not IsZero( tr[j] ) );
    if IsBound( r.blocks[i] ) then
      defect:= Concatenation( ", defect ", String( r.blocks[i][3] ) );
    else
      defect:= "";
    fi;

    Browse( rec(
        name:= r.name,
        d:= Concatenation( String( r.d ), " (block ", String( i ), defect, ")" ),
        decmat:= r.decmat{ pos }{ poss },
        hc_series:= r.hc_series{ poss },
        ordinary:= r.ordinary{ pos },
        origin:= r.origin ) );
    end);

