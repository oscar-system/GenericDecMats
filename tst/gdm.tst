gap> START_TEST( "gdm.tst" );

##  Run over the database.
gap> for name in GenericDecompositionMatricesNames() do
>      mat:= GenericDecompositionMatrix( name );
> 
>      # Check that the available 'recipe' fields are correct.
>      if IsBound( mat.recipe ) and
>         MatrixFromRecipe( mat.recipe, mat.decmat ) <> mat.decmat then
>        Error( "'mat.recipe' is not correct for '", name, "'" );
>      fi;
> 
>      # Check that the 'Browse' methods work.
>      BrowseData.SetReplay( "Q" );
>      Browse( mat );
>      BrowseData.SetReplay( false );
>      BrowseData.SetReplay( "Q" );
>      Browse( mat, 1 );
>      BrowseData.SetReplay( false );
>    od;

##
gap> STOP_TEST( "gdm.tst" );
