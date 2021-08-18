# This builds derivation, that contains sandbox with multiple
# specified apps and creates simple script to run it in bin folder.
#
# apps - list of paths to the apps, for example: [ "${app-textarea}/app-textarea" <other apps> ]
{ pname, version, sandbox, lib, stdenv, nodePackages, apps ? [ ] }:
let
  listOfLocations = lib.lists.foldl (list: app: "${list} ${app}") "" apps;
in stdenv.mkDerivation {
  inherit pname version;

  src = sandbox;

  buildPhase = ''
    # Copy all programs to their proper locations  
    for app in ${listOfLocations}; do
        cp -r $app ./
    done;

    # Simple server hosting script, see: buildWebShellApp.nix
    rm -r bin/*
    cat > bin/${pname} << EOL
    #!/bin/sh
    ${nodePackages.http-server}/bin/http-server \\
    EOL
    echo $out >> bin/${pname}
    chmod +x bin/${pname}
  '';

  installPhase = ''
    mkdir $out
    cp -r ./* $out
  '';
}
