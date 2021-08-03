# Builds app in a typical "Web Shell" way.
# Resulting derivation contains of 3 folders
# docs - For compatibility with github pages, mainly for deployment
# <Name of the app> - For public urls as in parcel, needed for testing with python web server
# bin - Contains script with the name of the program, that starts server that hosts desired package
{
  final, prev, napalm, src, pname, version,
  additionalBuildCommand ? "cd src; NODE_ENV=production parcel build index.html --public-url=/${pname}/ --out-dir=../docs; cd ..",
  packageLock ? null,
  npmCommands ? [ "npm install --loglevel verbose" "npm run build" ]
}:
let
  app-data = (napalm.overlay final prev).napalm.buildPackage src ({
    inherit npmCommands;
    buildInputs = with final; [ nodePackages.parcel-bundler ];
  } // (if ! isNull packageLock then { inherit packageLock; } else { }));
in
final.stdenv.mkDerivation {
  inherit version pname;
  src = app-data;

  buildInputs = with final; [ nodePackages.parcel-bundler ];

  buildPhase = ''
    cd _napalm-install

    ${additionalBuildCommand}
    # This is my custom script for testing server
    # 
    # It uses simple python server, which behaves similary
    # to the github pages, which are used in production
    mkdir bin
    cat > bin/${pname} << EOL
    #!/bin/sh
    ${final.python3}/bin/python3 -m http.server --directory \\
    EOL
    echo $out >> bin/${pname}
    chmod +x bin/${pname}
  '';

  installPhase = ''
    mkdir -p $out/${pname}
    cp -rd docs bin $out
    cp -rd docs/* $out/${pname}
  '';
}
