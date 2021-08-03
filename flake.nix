{
  description = "An open-source online desktop environment";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.napalm.url = "github:nix-community/napalm";

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

      # Custom sandbox run script app
      sandboxApp = self: system: {
        type = "app";
        program = "${self.packages.${system}.sandbox}/bin/run.sh";
      };

      buildWebShellApp = import ./buildWebShellApp.nix;
    in {
      # A Nixpkgs overlay.
      overlay = final: prev: rec {
        sandbox = buildWebShellApp {
          inherit final prev napalm version;
          pname = "sandbox";

          src = webshell-sandbox;
        };

        app-textarea = buildWebShellApp {
          inherit final prev napalm version;
          pname = "app-textarea";

          src = webshell-app-textarea;
          packageLock = ./package-locks/app-textarea.json;
        };

        app-example-image = buildWebShellApp {
          inherit final prev napalm version;
          pname = "app-example-image";

          src = webshell-app-example-image;
          packageLock = ./package-locks/app-example-image.json;
          additionalBuildCommand = ''
            mkdir docs
            cp ./*.html ./*.css ./*.js ./*.svg ./*.json docs
          '';
          npmCommands = [ "npm install" ];
        };

        app-ace = buildWebShellApp {
          inherit final prev napalm version;
          pname = "app-example-image";

          src = webshell-app-ace;
          packageLock = ./package-locks/app-ace.json;
          npmCommands = [ "npm install" "npm run build" ];
          additionalBuildCommand = "";
        };

        app-jsoneditor = buildWebShellApp {
          inherit final prev napalm version;
          pname = "app-jsoneditor";

          src = webshell-app-jsoneditor;
          packageLock = ./package-locks/app-jsoneditor.json;
          npmCommands = [ "npm install" "npm run build" ];
          #additionalBuildCommand = "";
        };

        app-quill = buildWebShellApp {
          inherit final prev napalm version;
          pname = "app-quill";

          src = webshell-app-quill;
          packageLock = ./package-locks/app-quill.json;
          npmCommands = [ "npm install" "npm run build" ];
          #additionalBuildCommand = "";
        };
      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system})
          sandbox app-textarea app-example-image app-ace app-jsoneditor app-quill;
      });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.sandbox);

      apps = forAllSystems (system: {
        sandbox = sandboxApp self system;
        app-textarea = {
          type = "app";
          program = "${self.packages.${system}.app-textarea}/bin/run.sh";
        };
      });

      defaultApp = forAllSystems (system: (sandboxApp self system));
    };
}
