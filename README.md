# Web Shell

- Project website: https://websh.org/
- Ngi issue: https://github.com/ngi-nix/ngi/issues/75

WebShell is an open-source online desktop environment.

This repo contains flake that allow user to easily build default WebShell apps as well as main sandbox.

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

## Status

Working packages:

- [x] Sandbox
- [x] App - Example Image
- [x] App - jsoneditor
- [x] App - quill
- [x] App - textarea
- [x] App - ace
- [x] Webshell - Full default webshell suite

