{ webshell, version, ... }:
webshell.buildSandboxWithApps {
  inherit version;
  pname = "webshell-full";

  inherit (webshell) sandbox;
  apps = with webshell; [
    app-textarea
    app-quill
    app-jsoneditor
    app-example-image
    app-ace
  ];
}
