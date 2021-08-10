{
  description = "An open-source online desktop environment";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  # Just to remind me that I need to push this into upstream
  inputs.napalm.url = "github:ngi-nix/napalm/node-gyp-fix";

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

      buildWebShellApp = final: { ... }@args : final.callPackage (import ./buildWebShellApp.nix) args;
      buildSandboxWithApps = final: { ... }@args : final.callPackage (import ./buildSanboxWithApps.nix) args;
    in {
      # A Nixpkgs overlay.
      overlay = final: prev: {
          # Most of WebShell programs do not have
          # parcel-builder in their package.json
          # so it needed to be added manually
          webshell = rec {
            sandbox = buildWebShellApp final {
              inherit version;
              pname = "sandbox";

              # Python3 is needed for node-gyp
              buildInputs = [ final.python3 ];
              src = webshell-sandbox;
            };

            app-textarea = buildWebShellApp final {
              inherit version;
              pname = "app-textarea";

              buildInputs = [ final.nodePackages.parcel-bundler ];
              src = webshell-app-textarea;
            };

            # This is very specific case, as this program
            # is a vanilla javascript app and does not
            # even have lock file
            app-example-image = buildWebShellApp final {
              inherit version;
              pname = "app-example-image";

              src = webshell-app-example-image;
              packageLock = ./package-locks/app-example-image.json;
              additionalBuildCommand = ''
                mkdir docs
                cp ./*.html ./*.css ./*.js ./*.svg ./*.json docs
              '';
              npmCommands = [ "npm install" ];
            };

            app-ace = buildWebShellApp final {
              inherit version;
              pname = "app-ace";

              buildInputs = [ final.nodePackages.parcel-bundler ];
              src = webshell-app-ace;
              packageLock = ./package-locks/app-ace.json;
            };

            app-jsoneditor = buildWebShellApp final {
              inherit version;
              pname = "app-jsoneditor";

              buildInputs = [ final.nodePackages.parcel-bundler ];
              src = webshell-app-jsoneditor;
            };

            app-quill = buildWebShellApp final {
              inherit version;
              pname = "app-quill";

              buildInputs = [ final.nodePackages.parcel-bundler ];
              src = webshell-app-quill;
            };

            full = buildSandboxWithApps final {
              inherit version;
              pname = "webshell-full";

              inherit sandbox;
              apps = [
                "${app-textarea}/app-textarea"
                "${app-quill}/app-quill"
                "${app-jsoneditor}/app-jsoneditor"
                "${app-example-image}/app-example-image"
                "${app-ace}/app-ace"
              ];
            };
          } // {
            # Export useful WebShell packaging functions in the overlay
            buildWebShellApp = buildWebShellApp final;
            buildSandboxWithApps = buildSandboxWithApps final;
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
