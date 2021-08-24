{ webshell, nodePackages, version, src, ... }:
webshell.buildWebShellApp {
    inherit version src;
    pname = "app-jsoneditor";

    buildInputs = [ nodePackages.parcel-bundler ];
}

