# Builds app in a typical "Web Shell" way with help of napalm package.
# Resulting derivation contains 3 folders
# docs - For compatibility with github pages, mainly for deployment
# <Name of the app> - For public urls as in parcel, needed for testing with python web server
# bin - Contains script with the name of the program, that starts server that hosts desired package
final: # Should be inherited from overlay
buildNapalmPackage: # It is basically: (napalm.overlay final prev).napalm.buildPackage
{ src, pname, version, # These are common derivation thing
  additionalBuildCommand ? "cd src; NODE_ENV=production parcel build index.html --public-url=/${pname}/ --out-dir=../docs; cd .." # This is build command that will be applied AFTER installing all npm related stuff that napalm does, usually you want to put here somthing from your package.json. In case of default WebShell apps it uses parcel to build everything into docs/ folder, you may want to modify this depending on your needs.
, packageLock ? null # This can be a path to custom package-lock.json file, if you can't/don't want to modify original's repo lock.
, npmCommands ? [ "npm install --loglevel verbose" "npm run build" ] # These are the commands that are executed by napalm, you usually want to specify this argument
}:
let
  app-data = buildNapalmPackage src ({
    inherit npmCommands version;
    name = pname;
    buildInputs = with final; [ nodePackages.parcel-bundler ];
  } // (if !isNull packageLock then { inherit packageLock; } else { }));
in final.stdenv.mkDerivation {
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
