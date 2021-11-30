gap> START_TEST( "gdm.tst" );

##  Run over the database.
gap> for name in GenericDecompositionMatricesNames() do
>      mat:= GenericDecompositionMatrix( name );
> 
>      # Check that the record is consistent.
>      res:= GDM_TestConsistency( name );
>      if res <> "" then
>        Print( "#E  inconsistent: '", name, "' (", res, ")\n" );
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
