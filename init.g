##############################################################################
##
##  Start GAP and read this file,
##  in order to load the generic decomposition matrices.
##
if LoadPackage( "JSON" ) <> true then
  Error( "the JSON package is needed in order to read data files" );
fi;

GDM_pkgdir:= CallFuncList(
    function()
    local currfile, currdir;

    currfile:= INPUT_FILENAME();
    currdir:= currfile{ [ 1 .. PositionSublist( currfile, "init.g" )-1 ] };
    if Length( currdir ) = 0 then
      return DirectoryCurrent();
    else
      return Directory( currdir );
    fi;
    end, [] );

Read( Filename( GDM_pkgdir, "gap/gdm.g" ) );

