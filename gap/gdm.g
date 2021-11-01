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
#F  GDM_GAP_record_from_JSON( <string> )
##
##  For a string <string> that is a JSON text encoding a generic decomposition
##  matrix, return the corresponding GAP record.
##
GDM_GAP_record_from_JSON:= function( string )
    local scan, nam, indets, fam, indetsindices, i, m, n;

    scan:= JsonStringToGap( string );

    # Insert 'name' and 'vars'.
    scan.name:= [ scan.type, scan.n ];
    scan.vars:= rec();
    if IsBound( scan.indets ) and Length( scan.indets ) > 0 then
      for nam in scan.indets do
        scan.vars.( nam ):= Indeterminate( Integers, nam );
      od;

      # Construct the decomposition matrix.
      indets:= List( scan.indets, nam -> Indeterminate( Integers, nam ) );
      fam:= FamilyObj( indets[1] );
      indetsindices:= List( scan.indets,
                            nam -> Position( fam!.namesIndets, nam ) );
    fi;
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

    return scan;
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
#F  GenericDecompositionMatrix( <name> )
#F  GenericDecompositionMatrix( <type>, <n>, <d> )
##
GenericDecompositionMatrix:= function( arg )
    local name, file;

    if Length( arg ) = 1 and IsString( arg[1] ) then
      name:= arg[1];
    elif Length( arg ) = 3 and IsString( arg[1] )
         and IsPosInt( arg[2] ) and IsPosInt( arg[3] ) then
      name:= Concatenation( arg[1], String( arg[2] ), "d", String( arg[3] ) );
    else
      Error( "usage: GenericDecompositionMatrix( <name> ) or\n",
             "GenericDecompositionMatrix( <type>, <n>, <d> )" );
    fi;

    file:= Filename( GDM_pkgdir, Concatenation( "data/", name, ".json" ) );
    if not IsExistingFile( file ) then
      return fail;
    fi;

    return GDM_GAP_record_from_JSON( StringFile( file ) );
end;


##############################################################################
##
#F  GenericDecompositionMatricesNames()
##
GenericDecompositionMatricesNames:= function()
    local dir, files;

    dir:= Filename( GDM_pkgdir, "data" );
    files:= Filtered( DirectoryContents( dir ), x -> EndsWith( x, ".json" ) );
    return List( files, x -> x{ [ 1 .. Position( x, '.' ) - 1 ] } );
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
#F  Browse( <decmat>[, <blocknr>] )
##
InstallMethod( Browse, [ IsRecord ],
    function(r)
    if not IsBound( r.decmat ) then
      TryNextMethod();
    fi;
    NCurses.BrowseDenseList( r.decmat, rec(
        header:= [ Concatenation( r.name[1], String( r.name[2] ),
                       ", d = ", String( r.d ) ) ],
        convertEntry:= NCurses.ReplaceZeroByDot,
        labelsCol:= [ r.hc_series ],
        labelsRow:= List( r.ordinary, x -> [ x ] ) ) );
    end );

InstallOtherMethod( Browse, [ IsRecord, IsInt ],
    function( r, i )
    local pos, tr, poss;

    if not IsBound( r.decmat ) then
      TryNextMethod();
    fi;
    pos:= Positions( r.blocklabels, i );
    tr:= TransposedMat( r.decmat{ pos } );
    poss:= Filtered( [ 1 .. Length( tr ) ], j -> not IsZero( tr[j] ) );
    Browse( rec(
        name:= r.name,
        d:= Concatenation( String( r.d ), " (block ", String( i ), ")" ),
        decmat:= r.decmat{ pos }{ poss },
        hc_series:= r.hc_series{ poss },
        ordinary:= r.ordinary{ pos } ) );
    end);

