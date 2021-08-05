{
  description = "An example of how to use Webshell";

  # Add nixpkgs input
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  # Add Webshell as your input flake
  inputs.webshell.url = "github:ngi-nix/webshell";
  # Some webshell app to be package:
  inputs.webshell-app-quill = {
    url = "github:websh-org/app-quill";
    flake = false;
  };

  outputs = { self, nixpkgs, webshell, webshell-app-quill }:
    let
      version = "0.2.1";

      # System types to support.
      # supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      supportedSystems = [ "x86_64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        });

    in {
      # A Nixpkgs overlay.
      overlay = final: prev:
        let
          # Load in builders
          buildWebShellApp = (webshell.overlay final prev).buildWebShellApp;
          buildSandboxWithApps =
            (webshell.overlay final prev).buildSandboxWithApps;
          sandbox = (webshell.overlay final prev).sandbox;
        in rec {
          # Example app
          app-quill = buildWebShellApp {
            inherit version;
            pname = "app-quill";

            src = webshell-app-quill;
          };

          # Package some app with sanbox
          custom-webshell-suite = buildSandboxWithApps {
            inherit version;
            pname = "custom-webshell-suite";

            inherit sandbox;
            apps = [ "${app-quill}/app-quill" ];
          };
        };

      # Provide your packages
      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}) app-quill custom-webshell-suite;
      });

      # Set default package as your suite
      defaultPackage =
        forAllSystems (system: self.packages.${system}.custom-webshell-suite);
    };
}
