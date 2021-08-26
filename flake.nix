{
  description = "An open-source online desktop environment";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  # Use my custom version of napalm, that isn't upstreamed yet
  inputs.napalm.url = "github:ngi-nix/napalm/npm-override";
  # Use flake-utils to reduce some generic code
  inputs.flake-utils.url = "github:numtide/flake-utils";

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

  outputs = { self, nixpkgs, flake-utils, webshell-sandbox
    , webshell-app-textarea, webshell-app-example-image, webshell-app-ace
    , webshell-app-jsoneditor, webshell-app-quill, napalm }:
    let version = "0.2.1";
    in {
      # A Nixpkgs overlay.
      overlay = final: prev:
        {
          # Most of WebShell programs do not have
          # parcel-builder in their package.json
          # so it needed to be added manually
          webshell = {
            sandbox = final.callPackage ./apps/sandbox.nix {
              inherit version;
              src = webshell-sandbox;
            };

            app-textarea = final.callPackage ./apps/app-textarea.nix {
              inherit version;
              src = webshell-app-textarea;
            };

            app-example-image = final.callPackage ./apps/app-example-image.nix {
              inherit version;
              src = webshell-app-example-image;
            };

            app-ace = final.callPackage ./apps/app-ace.nix {
              inherit version;
              src = webshell-app-ace;
            };

            app-jsoneditor = final.callPackage ./apps/app-jsoneditor.nix {
              inherit version;
              src = webshell-app-jsoneditor;
            };

            app-quill = final.callPackage ./apps/app-quill.nix {
              inherit version;
              src = webshell-app-quill;
            };

            full = final.callPackage ./apps/full.nix { inherit version; };

            # Export useful WebShell packaging functions in the overlay
            buildWebShellApp =
              final.callPackage ./buildWebShellApp.nix;
            buildSandboxWithApps =
              final.callPackage ./buildSanboxWithApps.nix;
          };
        } # This ensures propagation of napalm in the overlay:
        // (napalm.overlay final prev);

      defaultTemplate = {
        path = ./template;
        description = "Template for making custom Webshell apps and suites";
      };

    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        };
      in rec {
        packages = {
          inherit (pkgs.webshell)
            sandbox app-textarea app-example-image app-ace app-jsoneditor
            app-quill full;
        };

        # Default package and checks builds full
        # which consists of all of the apps.
        defaultPackage = pkgs.webshell.full;
        checks = pkgs.webshell.full;
      });
}
