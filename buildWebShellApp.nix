# Builds app in a typical "Web Shell" way with help of napalm package.
# Resulting derivation contains 3 folders
# docs - For compatibility with github pages, mainly for deployment
# <Name of the app> - For public urls as in parcel, needed for testing with python web server
# bin - Contains script with the name of the program, that starts server that hosts desired package
{ src, pname, version, # These are common derivation things
napalm, stdenv, nodePackages, nodejs, mkYarnModules, yarned ? false
, packageLock ? null # This can be a path to custom package-lock.json file, if you can't/don't want to modify original's repo lock.
, buildInputs ? [ ] # Additional build inputs
}:
let
  yarned-modules = mkYarnModules rec {
    inherit pname version;
    name = "${pname}-${version}";
    packageJSON = "${src}/package.json";
    yarnLock = "${src}/yarn.lock";
  };

in napalm.buildPackage src ({
  inherit version buildInputs;
  name = pname;

  npmCommands = [ "npm install --nodedir=${nodejs}/include/node" ]
    ++ (if yarned then [
      "cp -rf ${yarned-modules}/node_modules/* ./node_modules"
      "chmod -R +rw ./node_modules"
      "cp -rf ${yarned-modules}/deps ."
      "chmod -R +rw ./deps"
    ] else
      [ ]) ++ [ "npm run build" ];

  postBuild = ''
    mkdir bin
    cat > bin/${pname} << EOL
    #!/bin/sh
    ${nodePackages.http-server}/bin/http-server \\
    EOL
    echo $out >> bin/${pname}
  '';

  installPhase = ''
    mkdir -p "$out/"
    cp -rd docs bin $out
    cp -rd $out/docs $out/${pname}
  '';
} // (if !isNull packageLock then { inherit packageLock; } else { }))

