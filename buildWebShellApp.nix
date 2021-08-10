# Builds app in a typical "Web Shell" way with help of napalm package.
# Resulting derivation contains 3 folders
# docs - For compatibility with github pages, mainly for deployment
# <Name of the app> - For public urls as in parcel, needed for testing with python web server
# bin - Contains script with the name of the program, that starts server that hosts desired package

{ src, pname, version, # These are common derivation things
napalm, stdenv, nodePackages, python3, nodejs
, additionalBuildCommand ?
  "cd src; NODE_ENV=production parcel build index.html --public-url=/${pname}/ --out-dir=../docs; cd .." # This is build command that will be applied AFTER installing all npm related stuff that napalm does, usually you want to put here somthing from your package.json. In case of default WebShell apps it uses parcel to build everything into docs/ folder, you may want to modify this depending on your needs.
, packageLock ?
  null # This can be a path to custom package-lock.json file, if you can't/don't want to modify original's repo lock.
, npmCommands ? [
  "npm install --loglevel verbose --nodedir=${nodejs}/include/node"
  "npm run build"
] # These are the commands that are executed by napalm, you usually want to specify this argument
, buildInputs ? [ ] # Additional build inputs
}:
let
  app-data = napalm.buildPackage src ({
    inherit npmCommands version buildInputs;
    name = pname;
  } // (if !isNull packageLock then { inherit packageLock; } else { }));
in stdenv.mkDerivation {
  inherit version pname;
  src = app-data;

  buildInputs = [ nodePackages.npm ] ++ buildInputs;

  buildPhase = ''
    cd _napalm-install

    # Add npm binaries to the path
    export PATH="$(npm bin):$PATH"

    echo Running custom build command:
    echo "${additionalBuildCommand}" 

    ${additionalBuildCommand}
    # This is my custom script for testing server
    # 
    # It uses simple python server, which behaves similary
    # to the github pages, which are used in production
    mkdir bin
    cat > bin/${pname} << EOL
    #!/bin/sh
    ${python3}/bin/python3 -m http.server --directory \\
    EOL
    echo $out >> bin/${pname}
    chmod +x bin/${pname}
  '';

  installPhase = ''
    mkdir -p "$out/"
    cp -rd docs bin $out
    cp -rd $out/docs $out/${pname}
  '';
}
