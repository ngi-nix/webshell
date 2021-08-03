# Web Shell

- Project website: https://websh.org/
- Ngi issue: https://github.com/ngi-nix/ngi/issues/75

WebShell is an open-source online desktop environment.

## Status

Currently only main (sandbox) app is packaged:
```bash
nix build .
# or
nix build .#sandbox
```

It can also be runned (using python http server) via:
```bash
nix run .
# or
nix run .#sandbox
```