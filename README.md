# Web Shell

- Project website: https://websh.org/
- Ngi issue: https://github.com/ngi-nix/ngi/issues/75

WebShell is an open-source online desktop environment.

This repo contains flake that allows user to easily build default WebShell apps as well as the main sandbox. It also provides builders to package custom WebShell apps.

*This repo strongly relies on [Napalm project](https://github.com/nix-community/napalm), whenever I refer to `napalm`, I mean this project*

## Some tips how to use the flake

In order to view avaible packages, use:

```bash
nix flake show
```

In order to build package use:
```bash
nix build .#<Some package>
# or to build main app (Full Webshell suite):
nix build .
```

In order to run some app via simple python server, use:
```bash
nix run .#<Some package>
# or to run main app (Full Webshell suite):
nix run .
```

It is worth to mention that each app has it's own url, so for example to acces `sandbox` app via localhost, you need to open localhost:8000/sandbox.

## Using provided builders

Builders used in this flake are provided in the flake's overlay. If you want to get started with them, you can run `nix flake init -t "github:ngi-nix/webshell"`. This will create an example flake project.

### Available builders

Both builders with quite well documented signatures are available in their corresponding files:
- `buildWebShellApp.nix`
- `buildSanboxWithApps.nix`

They are intended to use with `flake.nix` (see template), but you can use them by clasically importing them as well, for example:
```nix
pkgs.callPackage (import ./buildWebShellApp.nix) {
  pname = "Example";
  version = "0.0.0";
  src = ./.;
}
```

## Packages Status

Working elements:

- [x] Sandbox
- [x] App - Example Image
- [x] App - jsoneditor
- [x] App - quill
- [x] App - textarea
- [x] App - ace
- [x] Webshell - Full default webshell suite
- [x] Custom builders
- [x] Template

