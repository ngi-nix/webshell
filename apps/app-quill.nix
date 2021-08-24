{ webshell, nodePackages, version, src, ... }:
webshell.buildWebShellApp {
  inherit version src;
  pname = "app-quill";

  buildInputs = [ nodePackages.parcel-bundler ];
}

