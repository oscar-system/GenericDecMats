##############################################################################
##
##  Start GAP in the directory that contains this file, and read this file,
##  in order to load the generic decomposition matrices.
##
if LoadPackage( "JSON" ) <> true then
  Error( "the JSON package is needed in order to read data files" );
fi;

#TODO: Fix this once we have a proper GAP package.
GDM_pkgdir:= Directory( "." );

Read( Filename( GDM_pkgdir, "gap/gdm.g" ) );

