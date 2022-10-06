##############################################################################
##
##  The GAP functions in this file are used to create a PDF file for each
##  available generic decomposition matrix.
##
##  The code has been derived from the corresponding GAP functions for
##  creating PDF files containing the decomposition matrices of ATLAS groups.
##  These PDF files can be found at
##    https://www.math.rwth-aachen.de/homes/MOC/decomposition/
##

GDM_ColsPerPage:= 15;
GDM_RowsPerPage:= 40;


#############################################################################
##
#F  GDM_LaTeXStringDecompositionMatrix( <arec>[, <blocknr>][, <options>] )
##
GDM_LaTeXStringDecompositionMatrix:= function( arg )
    local arec,          # data record, first argument
          blocknr,       # number of the block, optional second argument
          options,       # record with labels, optional third argument
          decmat,        # decomposition matrix
          block,         # block information on 'modtbl'
          collabels,     # indices of Brauer characters
          rowlabels,     # indices of ordinary characters
          phi,           # string used for Brauer characters
          chi,           # string used for ordinary irreducibles
          hlines,        # explicitly wanted horizontal lines
          ulc,           # text for the upper left corner
          r,
          k,
          n,
          rowportions,
          colportions,
          str,           # string containing the text
          i,             # loop variable
          val;           # one value in the matrix

    arec:= arg[1];

    # Get and check the arguments.
    if   Length( arg ) = 2 and IsRecord( arg[1] )
                           and IsRecord( arg[2] ) then
      options := arg[2];
    elif Length( arg ) = 2 and IsRecord( arg[1] )
                           and IsInt( arg[2] ) then
      blocknr := arg[2];
      options := rec();
    elif Length( arg ) = 3 and IsRecord( arg[1] )
                           and IsInt( arg[2] )
                           and IsRecord( arg[3] ) then
      blocknr := arg[2];
      options := arg[3];
    elif not( Length( arg ) = 1 and IsRecord( arg[1] ) ) then
      Error( "usage: GDM_LaTeXStringDecompositionMatrix(",
             " <arec>[, <blocknr>][, <options>] )" );
    fi;

    # Compute the decomposition matrix.
    decmat:= arec.decmat;

    # Choose default labels if necessary.
    rowportions:= [ [ 1 .. Length( decmat ) ] ];
    colportions:= [ [ 1 .. Length( decmat[1] ) ] ];

    phi:= "{\\tt Y}";
    chi:= "{\\tt X}";

    hlines:= [];
    ulc:= "";

    rowlabels:= arec.ordinary;
    collabels:= arec.hc_series;

    if IsBound( options ) then

      # Distribute to row and column portions if necessary.
      if IsBound( options.nrows ) then
        if IsInt( options.nrows ) then
          r:= options.nrows;
          n:= Length( decmat );
          k:= Int( n / r );
          rowportions:= List( [ 1 .. k ], i -> [ 1 .. r ] + (i-1)*r );
          if n > k*r then
            Add( rowportions, [ k*r + 1 .. n ] );
          fi;
        else
          rowportions:= options.nrows;
        fi;
      fi;
      if IsBound( options.ncols ) then
        if IsInt( options.ncols ) then
          r:= options.ncols;
          n:= Length( decmat[1] );
          k:= Int( n / r );
          colportions:= List( [ 1 .. k ], i -> [ 1 .. r ] + (i-1)*r );
          if n > k*r then
            Add( colportions, [ k*r + 1 .. n ] );
          fi;
        else
          colportions:= options.ncols;
        fi;
      fi;

      # Check for horizontal lines.
      if IsBound( options.hlines ) then
        hlines:= options.hlines;
      fi;

      # Check for text in the upper left corner.
      if IsBound( options.ulc ) then
        ulc:= options.ulc;
      fi;

    fi;

    Add( hlines, Length( decmat ) );

    # Construct the string.
    str:= "";

    for r in rowportions do

      for k in colportions do

        # Append the header of the array.
        Append( str,  "\\[\n" );
        Append( str,  "\\begin{array}{r|" );
        for i in k do
          Add( str, 'r' );
        od;
        Append( str, "} \\hline\n" );

        # Append the text in the upper left corner.
        if not IsEmpty( ulc ) then
          if r = rowportions[1] and k = colportions[1] then
            Append( str, ulc );
          else
            Append( str, Concatenation( "(", ulc, ")" ) );
          fi;
        fi;

        # The first line contains the Brauer character labels.
        for i in collabels{ k } do
          Append( str, " & " );
          Append( str, String( i ) );
          Append( str, "\n" );
        od;
        Append( str, " \\rule[-7pt]{0pt}{20pt} \\\\ \\hline\n" );

        # Append the matrix itself.
        for i in r do

          # The first column contains the numbers of ordinary irreducibles.
          Append( str, String( rowlabels[i] ) );

          for val in decmat[i]{ k } do
            Append( str, " & " );
            if IsZero( val ) then
              Append( str, "." );
            elif IsInt( val  ) then
              Append( str, String( val ) );
            else
              # The value is a polynomial.
              # We change the names of indeterminates such that
              # trailing digits are turned into subscripts.
              Append( str, GDM_string_from_polynomial( val ) );
            fi;
          od;

          if i = r[1] or i-1 in hlines then
            Append( str, " \\rule[0pt]{0pt}{13pt}" );
          fi;
          if i = r[ Length( r ) ] or i in hlines then
            Append( str, " \\rule[-7pt]{0pt}{5pt}" );
          fi;

          Append( str, " \\\\\n" );

          if i in hlines then
            Append( str, "\\hline\n" );
          fi;

        od;

        # Append the tail of the array
        Append( str,  "\\end{array}\n" );
        Append( str,  "\\]\n\n" );

      od;

    od;

    Unbind( str[ Length( str ) ] );
    ConvertToStringRep( str );

    # Return the result.
    return str;
end;


##############################################################################
##
#F  GDM_HeadingString( <type>, <n>, <d>, <condition> )
##
GDM_HeadingString:= function( type, n, d, condition )
    local str;

    type:= ReplacedString( type, "2A", "{}^2A" );
    type:= ReplacedString( type, "2D", "{}^2D" );

    str:= GDM_ConditionString( condition, "LaTeX" );
    if str = fail then
      Error( "strange conditions '", condition, "'" );
    fi;
    if str <> "" then
      str:= Concatenation( "\\ \\ (", str, ")" );
    fi;

    # preamble and header line
    return Concatenation( [
        "\\documentclass{article}\n",
        "\\pdfinfoomitdate 1  % reproducible output files\n",
        "\\usepackage[colorlinks=true,urlcolor=blue]{hyperref}\n",
        "\\pagestyle{empty}   % no page numbers\n",
        "\\textwidth15cm\n",
        "\\textheight 47\\baselineskip\n",
        "\\begin{document}\n",
        "\\mathversion{bold}  % for the heading only\n",
        "\\vspace*{-20pt}\n",
        "{\\LARGE $", type, "_{", String( n ), "}(q) \\bmod l, d = ",
        String( d ), "$}",
        str, "\n",
        "\\mathversion{normal}\n\n",
      ] );
end;


##############################################################################
##
#F  GDM_AppendMatrix( <str>, <decmat>, <ordlabels>, <modlabels> )
##
GDM_AppendMatrix:= function( str, r )
    local ordlabels, modlabels, decmat, ncols, ndigits, cols, j, offset,
          start, width, row, options;

    ordlabels:= r.ordinary;
    modlabels:= r.hc_series;
    decmat:= r.decmat;

    # Compute the maximal number of columns.
    # Consider
    # 2. length of ordinary labels
    # 3. length of Brauer labels

    ncols:= GDM_ColsPerPage;

    # 2. For each 5 digits in subscript, subtract one column.
    #    (count the digit characters, plus signs, commas,
    # and '\ast' occurrences)
    ndigits:= Maximum( List( ordlabels,
                             x -> Number( x, y -> IsAlphaChar(y) or
                                                  IsDigitChar(y) )
                                + Number( x, y -> y = ',' ) / 2
                                + Number( x, y -> y = '+' ) * 3/2 ) );
    ncols:= ncols - Int( ndigits / 5 );
    if ncols <= 0 then
      Error( "not enough space for a single column!" );
    fi;

    # 3. There are 'ncols * 5' digits free for the columns,
    #    and each '\varphi' plus intercolumn space need 3 digits space.
    cols:= [];
    j:= 1;
    offset:= 0;
    while j <= Length( modlabels ) do

      # Loop over column parts of the matrix.
      start:= j;
      ndigits:= ncols * 5 - offset;
      while ndigits >= 0 and j < Length( modlabels ) do
        j:= j+1;
        width:= Number( modlabels[j], y -> IsAlphaChar(y) or IsDigitChar(y) )
                + Number( modlabels[j], y -> y = ',' ) / 2
                + Number( modlabels[j], y -> y = '+' ) * 3/2;
        for row in decmat do
          width:= Maximum( width,
                      Length( ReplacedString( String( row[j] ), "*", "" ) ) );
        od;

        ndigits:= ndigits - width - 2;  # subtract 2 for intercolumn space
      od;
      if ndigits < 0 then
        Add( cols, [ start .. j-1 ] );
        offset:= width;
      else
        Add( cols, [ start .. j ] );
        j:= j+1;
        offset:= 0;
      fi;

    od;

    # Put the options together.
    options:= rec( nrows     := GDM_RowsPerPage,
                   ncols     := cols,
                   ulc       := "",
                   hlines    := [] );

    Append( str, "\n\\vspace*{10pt}\n" );

    # Add the matrix.
    Append( str, GDM_LaTeXStringDecompositionMatrix( r, options ) );
end;


##############################################################################
##
#F  GDM_Footer( <r> )
##
GDM_Footer:= function( r )
    local footer;

    footer:= JoinStringsWithSeparator(
                 List( SplitString( r.origin, "," ),
                       x -> Concatenation( "\\nocite{", x, "}" ) ), "\n" );
    Append( footer, "\\bibliographystyle{alpha}\n\\bibliography{gdm}\n" );
    return footer;
end;


##############################################################################
##
#F  GDM_CreateBibFile()
##
GDM_CreateBibFile:= function()
    FileString( "gdm.bib",
        Concatenation(
            List( RecNames( GDM_References ),
                  x -> StringBibXMLEntry( GDM_References.(x), "BibTeX" ) ) ) );
end;


##############################################################################
##
#F  GDM_MakeFile( <name> )
##
GDM_MakeFile:= function( name )
    local dirname, groupdirname, entry, p, issymm, primes, str, output, table,
          row, found, filename, r;

    # The directory is named after the simple group.
    dirname:= GDM_pkgdir;
    dirname:= Filename( dirname, "tex" );
    filename:= Concatenation( dirname, "/", name );

    # Load the record.
    r:= GenericDecompositionMatrix( name );

    # Start with the heading.
    str:= GDM_HeadingString( r.type, r.n, r.d, r.condition );

    # Append the nontrivial decomposition matrices.
    GDM_AppendMatrix( str, r );

    # Append the footer info about the paper(s) in question.
    Append( str, GDM_Footer( r ) );

    # Append the end of the file.
    Append( str, "\n\\end{document}\n" );

    # Print the string to a file.
    FileString( "current.tex", str );
    Exec( "date >> current.tex" );

    # If the bibliography file 'gdm.bib' is not yet available then create it.
    GDM_CreateBibFile();

    # Run 'pdflatex' and 'bibtex'.
    Exec( Concatenation( "echo \"", filename, "\" >> erfull.log" ) );
    Exec( "pdflatex current" );
    Exec( "bibtex current" );
    Exec( "pdflatex current" );
    Exec( "pdflatex current" );
    Exec( "grep erfull current.log >> erfull.log" );
    Exec( Concatenation( "mv current.pdf \"", filename, ".pdf\"" ) );
    Exec( Concatenation( "mv current.tex \"", filename, ".tex\"" ) );

    # Remove intermediate files.
    Exec( Concatenation( "cd \"", dirname, "\"; ",
                         "rm -rf current.aux current.log current.bbl current.blg current.out" ) );

    Print( "#I  ", name, " done\n" );
    return true;
end;


##############################################################################
##
#F  GDM_MakeAll( )
#F  GDM_MakeAll( <names> )
#F  GDM_MakeAll( <names>, <from> )
##
GDM_MakeAll:= function( arg )
    local names, pos, i, entry;

    if Length( arg ) = 2 then
      names:= arg[1];
      pos:= arg[2];
    elif Length( arg ) = 1 then
      names:= arg[1];
      pos:= 1;
    else
      names:= GenericDecompositionMatricesNames();
      pos:= 1;
    fi;

    for i in [ pos .. Length( names ) ] do
      entry:= names[i];
      Print( "#I  ", Ordinal( i ), " matrix: ", entry, "\n" );
      GDM_MakeFile( entry );
      Print( "\n" );
    od;
end;


##############################################################################
##
#F  GDM_HTMLTableString()
##
##  This function returns a string describing a HTML overview of the
##  available generic decomposition matrices,
##  used in the 'index.html' file of the site with the PDF files.
##
GDM_HTMLTableString:= function()
    local names, types, html_types, i, type, namesbytype, name, str, ns, pos,
          ds, j, nstr;

    names:= Filtered( GenericDecompositionMatricesNames(),
                x -> IsExistingFile( Filename( GDM_pkgdir,
                         Concatenation( "tex/", x, ".pdf" ) ) ) );

    # Sort the names in such a way that names differing by number substrings
    # are ordered according to the numbers;
    # e.g., 'A5' shall precede 'A10'.
    Sort( names, BrowseData.CompareAsNumbersAndNonnumbers );

    types:= [ "A", "2A", "B", "D", "2D", "3D4", "E6", "2E6", "E7", "F4", "G2" ];
    html_types:= ShallowCopy( types );
    for i in [ 1 .. Length( types ) ] do
      if IsDigitChar( types[i][1] ) then
        type:= html_types[i];
        html_types[i]:= Concatenation( "<sup>", [ type[1] ], "</sup>",
                            type{ [ 2 .. Length( type ) ] } );
      fi;
      if IsDigitChar( types[i][ Length( types[i] ) ] ) then
        type:= html_types[i];
        html_types[i]:= Concatenation( type{ [ 1 .. Length( type )-1 ] },
                            "<sub>", [ type[ Length( type ) ] ], "</sub>" );
      fi;
    od;

    namesbytype:= List( types, x -> [] );
    for name in names do
      for i in [ 1 .. Length( types ) ] do
        if StartsWith( name, types[i] ) then
          Add( namesbytype[i], name );
          break;
        fi;
      od;
    od;

    str:= "<dl>";
    for i in [ 1 .. Length( types ) ] do
      ns:= [];
      for name in namesbytype[i] do
        pos:= Position( name, 'd' );
        AddSet( ns, Int( name{ [ Length( types[i] )+1 .. pos-1 ] } ) );
      od;
      ds:= List( ns, x -> [] );
      for name in namesbytype[i] do
        for j in [ 1 .. Length( ns ) ] do
          if ns[j] = 0 then
            nstr:= "";
          else
            nstr:= String( ns[j] );
          fi;
          if StartsWith( name, Concatenation( types[i], nstr, "d" ) ) then
            Add( ds[j], name );
            break;
          fi;
        od;
      od;

      for j in [ 1 .. Length( ns ) ] do
        Append( str, "<dt>" );
        Append( str, html_types[i] );
        Append( str, "<sub>" );
        Append( str, String( ns[j] ) );
        Append( str, "</sub></dt>\n<dd>" );
        Append( str, JoinStringsWithSeparator(
                         List( ds[j], d -> Concatenation( "<a href=\"",
                               d, ".pdf\">", d, "</a>" ) ), ", " ) );
        Append( str, "</dd>\n" );
      od;
    od;
    Append( str, "</dl>\n\n" );

    return str;
end;


##############################################################################
##
#E

