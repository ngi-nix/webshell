{ webshell, nodePackages, version, src, ... }:
webshell.buildWebShellApp {
    inherit version src;
    pname = "app-textarea";

    buildInputs = [ nodePackages.parcel-bundler ];
}
