{ webshell, python3, version, src, ... }:
webshell.buildWebShellApp {
  inherit version src;
  pname = "sandbox";

  yarned = true;
  # Python3 is needed for node-gyp
  buildInputs = [ python3 ];
}
