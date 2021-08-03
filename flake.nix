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

  outputs = { self, nixpkgs, webshell-sandbox, webshell-app-textarea, napalm }:
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
    in {
      overlays = [ napalm.overlay ];
      
      # A Nixpkgs overlay.
      overlay = final: prev: rec {
        sandbox = let
          sandbox-data =
            (napalm.overlay final prev).napalm.buildPackage webshell-sandbox {
              npmCommands = [ "npm install --ignore-scripts" "npm run build" ];
            };
        in with final;
        stdenv.mkDerivation {
          inherit version;
          pname = "sandbox";

          src = sandbox-data;

          buildInputs = [ nodePackages.parcel-bundler ];

          buildPhase = ''
            cd _napalm-install

            cd src; NODE_ENV=production parcel build index.html --out-dir=../docs; cd ..
            # This is my custom script for testing server
            # 
            # It uses simple python server, which behaves similary
            # to the github pages, which are used in production
            mkdir bin
            cat > bin/run.sh << EOL
            #!/bin/sh
            ${final.python3}/bin/python3 -m http.server --directory \\
            EOL
            echo $out >> bin/run.sh
            chmod +x bin/run.sh
          '';

          installPhase = ''
            mkdir -p $out/sandbox
            cp -rd docs bin $out
            cp -rd docs/* $out/sandbox
          '';
        };

        app-textarea = let
          textarea-data =
            (napalm.overlay final prev).napalm.buildPackage webshell-app-textarea {
              npmCommands = [ "npm install --ignore-scripts" "npm run build" ];
              buildInputs = with final; [ nodePackages.parcel-bundler ];
              packageLock = ./package-lock.json;
            };
        in with final;
        stdenv.mkDerivation {
          inherit version;
          pname = "app-textarea";

          src = textarea-data;

          buildInputs = [ nodePackages.parcel-bundler ];

          buildPhase = ''
            cd _napalm-install

            cd src; NODE_ENV=production parcel build index.html --public-url=/app-textarea --out-dir=../docs; cd ..

            # This is my custom script for testing server
            # 
            # It uses simple python server, which behaves similary
            # to the github pages, which are used in production
            mkdir bin
            cat > bin/run.sh << EOL
            #!/bin/sh
            ${final.python3}/bin/python3 -m http.server --directory \\
            EOL
            echo $out >> bin/run.sh
            chmod +x bin/run.sh
          '';

          installPhase = ''
            mkdir -p $out/app-textarea
            cp -rd docs bin $out
            cp -rd docs/* $out/app-textarea
          '';
        };
      };

      # Provide some binary packages for selected system types.
      packages =
        forAllSystems (system: { inherit (nixpkgsFor.${system}) sandbox app-textarea; });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage =
        forAllSystems (system: self.packages.${system}.sandbox);

      apps = forAllSystems (system:
        {
          sandbox = sandboxApp self system;
          app-textarea = {
            type = "app";
            program = "${self.packages.${system}.app-textarea}/bin/run.sh";
          };
        });

      defaultApp = forAllSystems (system: (sandboxApp self system));
    };
}
