{ stdenv, nodePackages, runtimeShell, version, src, ... }:
# This is very specific case, as this program
# is a vanilla javascript app and does not
# even have lock file
stdenv.mkDerivation rec {
    inherit version src;
    pname = "app-example-image";

    buildPhase = ''
    mkdir docs
    find . -type f -exec mv {} docs/ \;

    mkdir bin
    cat > bin/${pname} << EOL
    #!${runtimeShell}
    ${nodePackages.http-server}/bin/http-server $out
    EOL
    chmod +x bin/${pname}
    '';

    installPhase = ''
    mkdir -p "$out/"
    cp -rd docs bin $out
    cp -rd $out/docs $out/${pname}
    '';
}
