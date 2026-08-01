# nur-packages

Personal [NUR](https://github.com/nix-community/NUR) repository.

## Packages

- `acac-cli`
- `aclogin`
- `atcoder-cli`
- `beatoraja`
- `bit-vcs`
- `bumblebee`
- `buzz`
- `buzz-acp`
- `codex-limit-auto-reset`
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
- `mcp-searxng`
- `nature-remo-cli`
- `nlobby-cli`
- `oracle`
- `opensrc`
- `pi-acp`
- `polycat`
- `pretty-ts-errors-markdown`
- `pyproject-build-systems`
- `pyproject-nix`
- `readout`
- `rinkaku`
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
- `turbowarp-desktop`
- `twitter-api-safe-mcp`
- `uv2nix`
- `waza`

## Usage

Import this repo through NUR or use [overlay.nix](./overlay.nix) as a nixpkgs overlay.

Run `twitter-api-safe-mcp /path/to/settings.json` to start the Twitter/X MCP
server. Stdio clients must set `"mcp": { "transport": "stdio" }` in that
settings file. Configure a system browser executable or CDP endpoint in the
profile settings; browser binaries are not bundled with the package.

The flake also exports `nixosModules.twitter-api-safe-mcp`, which generates the
settings file and runs the package as a native systemd service:

```nix
{
  imports = [ inputs.nur-packages.nixosModules.twitter-api-safe-mcp ];

  services.twitter-api-safe-mcp = {
    enable = true;
    settings.profiles = [
      {
        name = "account1";
        browser = {
          type = "cdp";
          browserType = "chromium";
          cdpEndpoint = "http://127.0.0.1:9224";
        };
      }
    ];
  };
}
```

The generated settings file is stored in the Nix store. Do not put passwords,
tokens, or other secrets in `services.twitter-api-safe-mcp.settings`.

`screenpipe-app` and `screenpipe-cli` are built from the pinned upstream source.
They use the unfree Screenpipe Commercial License; check the upstream terms
before business or production use.

`nixosModules.codex-limit-auto-reset` runs the package as the user whose Codex
authentication it should use:

```nix
{
  imports = [ inputs.nur-packages.nixosModules.codex-limit-auto-reset ];

  services.codex-limit-auto-reset = {
    enable = true;
    user = "alice";
    codexHome = "/home/alice/.codex";
  };
}
```

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
