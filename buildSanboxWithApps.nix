# This builds derivation, that contains sandbox with multiple
# specified apps and creates simple script to run it in bin folder.
#
# apps - list of paths to the apps, for example: [ "${app-textarea}/app-textarea" <other apps> ]
{ pname, version, sandbox, lib, stdenv, nodePackages, apps ? [ ] }:
let
  appsLocations = lib.lists.foldl (list: app: "${list} ${app}/${app.pname}") "" apps;

  # TODO: Figure this thing out
  knownApps =
    lib.foldl (set: subset: set // subset) {}
    (builtins.map
      (app: if builtins.pathExists (app + ./app-manifest.json) then { "webshell:app:../${app.pname}" = builtins.fromJSON (builtins.readFile "${app}/app-manifest.json"); } else {}) apps);

in stdenv.mkDerivation {
  inherit pname version;

  src = sandbox;

  buildPhase = ''
    # Copy all programs to their proper locations  
    for app in ${appsLocations}; do
        cp -r $app ./
    done;

    # Simple server hosting script, see: buildWebShellApp.nix
    rm -r bin/*
    cat > bin/${pname} << EOL
    #!/bin/sh
    ${nodePackages.http-server}/bin/http-server $out
    EOL
    chmod +x bin/${pname}

    #echo ${builtins.toJSON knownApps} > docs/known.apps.json
  '';

  installPhase = ''
    mkdir $out
    cp -r ./* $out
  '';
}
