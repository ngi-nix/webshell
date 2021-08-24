{
  description = "An open-source online desktop environment";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  # Just to remind me that I need to push this into upstream
  inputs.napalm.url = "github:ngi-nix/napalm/npm-override";

  # Web shell repos:
  inputs.webshell-sandbox = {
    url = "github:websh-org/sandbox";
    flake = false;
  };
  inputs.webshell-app-textarea = {
    url = "github:websh-org/app-textarea";
    flake = false;
  };
  inputs.webshell-app-example-image = {
    url = "github:websh-org/app-example-image";
    flake = false;
  };
  inputs.webshell-app-ace = {
    url = "github:websh-org/app-ace";
    flake = false;
  };
  inputs.webshell-app-jsoneditor = {
    url = "github:websh-org/app-jsoneditor";
    flake = false;
  };
  inputs.webshell-app-quill = {
    url = "github:websh-org/app-quill";
    flake = false;
  };

  outputs = { self, nixpkgs, webshell-sandbox, webshell-app-textarea
    , webshell-app-example-image, webshell-app-ace, webshell-app-jsoneditor
    , webshell-app-quill, napalm }:
    let
      version = "0.2.1";

      # System types to support.
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" ];

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
      overlay = final: prev: {
          # Most of WebShell programs do not have
          # parcel-builder in their package.json
          # so it needed to be added manually
          webshell = {
            sandbox = final.callPackage ./apps/sandbox.nix { inherit version; src = webshell-sandbox; };

            app-textarea = final.callPackage ./apps/app-textarea.nix { inherit version; src = webshell-app-textarea; };

            app-example-image = final.callPackage ./apps/app-example-image.nix { inherit version; src = webshell-app-example-image; };
            
            app-ace = final.callPackage ./apps/app-ace.nix { inherit version; src = webshell-app-ace; };

            app-jsoneditor = final.callPackage ./apps/app-jsoneditor.nix { inherit version; src = webshell-app-jsoneditor; };

            app-quill = final.callPackage ./apps/app-quill.nix { inherit version; src = webshell-app-quill; };

            full = final.callPackage ./apps/full.nix { inherit version; };

            # Export useful WebShell packaging functions in the overlay
            buildWebShellApp = final.callPackage (import ./buildWebShellApp.nix);
            buildSandboxWithApps = final.callPackage (import ./buildSanboxWithApps.nix);
          }; 
      } # This ensures propagation of napalm in the overlay:
      // (napalm.overlay final prev);

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}.webshell)
          sandbox app-textarea app-example-image app-ace app-jsoneditor
          app-quill full;
      });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.full);

      checks = self.packages;

      defaultTemplate = {
        path = ./template;
        description = "Template for making custom Webshell apps and suites";
      };
    };
}
