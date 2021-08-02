# Web Shell

- Project website: https://websh.org/
- Ngi issue: https://github.com/ngi-nix/ngi/issues/75

WebShell is an open-source online desktop environment.

## Status

Currently it is possible to create basic sandbox app via:

```bash
nix build .
```

Then you can test it out via some basic web server (sanbox is being build into docs folder), for example:

```
cd result && python3 -m http.server --directory ./docs
```
