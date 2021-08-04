# Web Shell

- Project website: https://websh.org/
- Ngi issue: https://github.com/ngi-nix/ngi/issues/75

WebShell is an open-source online desktop environment.

This repo contains flake that allow user to easily build default WebShell apps as well as main sandbox.

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

## Lib

This flake provides small library containing builders/functions, that help with deploying your own Web Shell apps. These functions are specified in the `lib` attribute of the flake. Both of them are intended to use in flake overlays. These functions with some comments are defined in the corresponding `.nix` files, but for convinience I have copied their "headers" below:

**WARNING: These builders are not final and may change in the future**

`buildWebShellApp`:
```nix
# Builds app in a typical "Web Shell" way with help of napalm package.
# Resulting derivation contains 3 folders
# docs - For compatibility with github pages, mainly for deployment
# <Name of the app> - For public urls as in parcel, needed for testing with python web server
# bin - Contains script with the name of the program, that starts server that hosts desired package
{ final, prev, napalm, # These should be inherited from overlay arguments and flake inputs
  src, pname, version, # These are common derivation thing
  additionalBuildCommand ? "cd src; NODE_ENV=production parcel build index.html --public-url=/${pname}/ --out-dir=../docs; cd .." # This is build command that will be applied AFTER installing all npm related stuff that napalm does, usually you want to put here somthing from your package.json. In case of default WebShell apps it uses parcel to build everything into docs/ folder, you may want to modify this depending on your needs.
, packageLock ? null # This can be a path to custom package-lock.json file, if you can't/don't want to modify original's repo lock.
, npmCommands ? [ "npm install --loglevel verbose" "npm run build" ] # These are the commands that are executed by napalm, you usually want to specify this argument
}:
```

`buildSanboxWithApps`:
```nix
# This builds derivation, that contains sandbox with multiple
# specified apps and creates simple script to run it in bin folder.
#
# apps - list of paths to the apps, for example: [ "${app-textarea}/app-textarea" <other apps> ]
{ final, prev, pname, version, sandbox, apps ? [ ] }:
```

## Packages Status

Working packages:

- [x] Sandbox
- [x] App - Example Image
- [x] App - jsoneditor
- [x] App - quill
- [x] App - textarea
- [x] App - ace
- [x] Webshell - Full default webshell suite

