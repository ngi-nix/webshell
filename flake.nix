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

  inputs.webshell-webapp = {
    url = "github:websh-org/web-shell-app";
    flake = false;
  };

  outputs = { self, nixpkgs, webshell-sandbox, webshell-webapp, napalm }:
    let
      # Generate a user-friendly version numer.
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
    in {
      overlays = [ napalm.overlay ];
      
      # A Nixpkgs overlay.
      overlay = final: prev: rec {
        sandbox = let
          sandbox-data =
            (napalm.overlay final prev).napalm.buildPackage webshell-sandbox {
              npmCommands = [ "npm install --ignore-scripts" "npm run build" ];
              buildInputs = with final; [ python nodePackages.node-gyp ];
            };
        in with final;
        stdenv.mkDerivation {
          inherit version;
          pname = "sandbox";

          src = sandbox-data;

          buildInputs = [ nodePackages.parcel-bundler ];

          buildPhase = ''
            cd _napalm-install
            cd src
            NODE_ENV=production parcel build index.html --out-dir=../docs --global WebShellSandbox
            cd ..
          '';

          installPhase = ''
            mkdir -p $out
            cp -r ./* $out
          '';
        };

        webapp = let
          webapp-data =
            (napalm.overlay final prev).buildPackage webshell-webapp {
              npmCommands = [ "npm install" "npm run build" ];
              buildInputs = with final; [ python nodePackages.node-gyp ];
            };
        in with final;
        stdenv.mkDerivation {
          inherit version;
          pname = "webapp";

          src = webapp-data;

          buildInputs = [ nodePackages.parcel-bundler ];

          buildPhase = ''
            cd _napalm-install
            NODE_ENV=production parcel build index.html --out-dir=dist --global WebShellWebApp
          '';

          installPhase = ''
            mkdir -p $out
            cp -r ./* $out
          '';
        };
      };

      # Provide some binary packages for selected system types.
      packages =
        forAllSystems (system: { inherit (nixpkgsFor.${system}) sandbox webapp; });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage =
        forAllSystems (system: self.packages.${system}.sandbox);
    };
}
