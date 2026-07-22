# nur-packages

Personal [NUR](https://github.com/nix-community/NUR) repository.

## Packages

- `acac-cli`
- `aclogin`
- `atcoder-cli`
- `beatoraja`
- `bit-vcs`
- `bumblebee`
- `codexbar-waybar`
- `continues`
- `course-cli`
- `cucumber-language-server`
- `defuddle`
- `difit`
- `gctx`
- `gh-actions-language-server`
- `ghidra-mcp`
- `ghidra-mcp-bridge`
- `git-now`
- `jj-desc`
- `jportaudio`
- `katasu`
- `keifu`
- `man-pages-ja`
- `nlobby-cli`
- `oracle`
- `opensrc`
- `polycat`
- `pretty-ts-errors-markdown`
- `pyproject-build-systems`
- `pyproject-nix`
- `readout`
- `roots`
- `screenpipe-app`
- `screenpipe-cli`
- `tfmv`
- `tree-sitter-moonbit-grammar`
- `similarity-ts`
- `skill-scanner`
- `skillspector`
- `symphony`
- `tunnelto`
- `twitter-api-safe-relay-mcp`
- `uv2nix`
- `waza`

## Usage

Import this repo through NUR or use [overlay.nix](./overlay.nix) as a nixpkgs overlay.

`screenpipe-app` and `screenpipe-cli` are built from the pinned upstream source.
They use the unfree Screenpipe Commercial License; check the upstream terms
before business or production use.

GhidraMCP 1.4 targets Ghidra 11.3.2. Compose it with the compatible Ghidra
derivation exposed by the package:

```nix
let
  extension = pkgs.ghidra-mcp;
in
extension.ghidra.withExtensions (_: [ extension ])
```

`ghidra-mcp` provides the official 1.4 extension loaded into Ghidra. MCP
clients launch the separate `ghidra-mcp-bridge` executable, pinned to upstream
PR 123, which adds pooled HTTP connections and configurable decompilation
timeouts.
