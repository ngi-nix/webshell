{ webshell, nodePackages, version, src, ... }:
webshell.buildWebShellApp {
    inherit version src;
    pname = "app-ace";

    buildInputs = [ nodePackages.parcel-bundler ];
    packageLock = ./package-locks/app-ace.json;
}
