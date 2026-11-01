# nur-packages

Personal [NUR](https://github.com/nix-community/NUR) repository.

## Packages

- `acac-cli`
- `aclogin`
- `atcoder-cli`
- `beatoraja`
- `beeper-cli`
- `beeper-server` (headless nightly, x86_64-linux)
- `bit-vcs`
- `bumblebee`
- `buzz`
- `buzz-acp`
- `cccc-moznion` (moznion's complexity analyzer; command: `cccc`)
- `codex-limit-auto-reset`
- `codex-security`
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
- `herdr-app` (Linux desktop app, built from source)
- `herdr-core` (terminal server; command: `hc`)
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
- `ptrlib`
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
- `xurl`

## Usage

Import this repo through NUR or use [overlay.nix](./overlay.nix) as a nixpkgs overlay.

`ptrlib` is a Python library rather than a command-line application. Add it to
a Python environment when consuming the overlay:

```nix
pkgs.python3.withPackages (_: [ pkgs.ptrlib ])
```

Run `twitter-api-safe-mcp /path/to/settings.json` to start the Twitter/X MCP
server. Stdio clients must set `"mcp": { "transport": "stdio" }` in that
settings file. Configure a system browser executable or CDP endpoint in the
profile settings; browser binaries are not bundled with the package.

`beeper-cli` installs the command as `beeper-cli` so it can coexist with the
`beeper` desktop package. Beeper Desktop already includes its MCP server; no
separate MCP package is needed.

`beeper-server` packages the headless Client API server for `x86_64-linux`,
pinned to nightly version `4.3.149`. It can run without Beeper Desktop. Manage
its service and persistent data directory separately; the package does not
perform login or install a service.

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

`homeModules.codex-limit-auto-reset` runs the package as a systemd user service.
Import it in the user's Home Manager configuration:

```nix
{
  imports = [ inputs.nur-packages.homeModules.codex-limit-auto-reset ];

  programs.codex.enable = true;
  services.codex-limit-auto-reset.enable = true;
}
```

The service uses `programs.codex.package` when Codex is enabled, and otherwise
uses `pkgs.codex`. It explicitly passes `CODEX_HOME` from
`home.sessionVariables.CODEX_HOME`, falling back to `~/.codex` when unset.
Override `services.codex-limit-auto-reset.codexPackage` or `codexHome` only when
this service should use a different CLI or authentication directory.

Enable `users.users.<name>.linger = true` in NixOS to start the user manager at
boot and keep it running after logout. Inspect the service with
`systemctl --user status codex-limit-auto-reset`. When migrating from the old
NixOS module, remove its import and `services.codex-limit-auto-reset` system
configuration before enabling this Home Manager module to avoid two workers
redeeming the same account's credits.

The package pins the [personal fork](https://github.com/yutakobayashidev/codex-limit-auto-reset)
with structured JSON daemon logs. Only `credit_redemption_result` events with
`outcome="reset"` represent confirmed resets; retry failures and other outcomes
are separate events. The underlying scheduling and credit ID idempotency key
remain unchanged. Authentication and raw RPC error payloads are not logged by
the event logger.

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

## Grafana calendar heatmap

`grafana-calendar-heatmap` packages the signed Grafana catalog release of
`tim012432-calendarheatmap-panel`. Add it to
`services.grafana.declarativePlugins` to display daily activity as a GitHub-style
calendar. Version 1.2.1 supports the dashboard timezone and requires Grafana
`>=12.1.7 <12.2` or `>=12.2.5`. The package keeps the plugin signature intact;
unsigned-plugin exceptions are not needed.

## Herdr desktop app

`herdr-app` includes a desktop entry and uses the packaged `herdr-core` on its
PATH. Both build from source on Linux. The app follows the Nix support in
[upstream PR #51](https://github.com/herdrdev/herdr-app/pull/51), pinned to its
fork revision until that work is merged.

The packaging is adapted from [lorenzorapetti/nix](https://github.com/lorenzorapetti/nix/tree/a4ce94d8b64daa2ddc5e02d3fff690b1d17ca693/modules/desktop/applications).
Its MIT license is preserved in `pkgs/herdr-app/LICENSE.packaging`. When
updating either package, refresh the source, Ghostty submodule, Zig dependency
and Cargo hashes together; keep core at or above the app’s
`distribution/core-version`.

## Tibo reset monitor

`tibo-reset-monitor` polls the [Codex Resets public API](https://codex-resets.com/api/openapi.json)
and sends newly tracked reset announcements to Discord. It distinguishes regular
resets, banked reset credits, and observed events, displaying announcement/first
observation time in Japan and US Pacific time (including daylight saving time).
The tracker is unofficial; forecasts and scheduled resets are not consumed.

```sh
tibo-reset-monitor --state-dir /var/lib/tibo-reset-monitor \
  --webhook-file /run/credentials/tibo-reset-monitor.service/discord-webhook
```

Run it periodically, for example with a five-minute systemd timer. Pass the
secret webhook through a credential file, never command-line text or the Nix
store. The first successful poll silently records all existing IDs. Later polls
read all cursor pages, notify new IDs oldest first, and persist each successful
Discord acknowledgement in SQLite. Preserve the state directory across upgrades;
deleting it starts a new silent baseline. An exclusive lock prevents concurrent
invocations from sending duplicate notices. Rate-limit backoff survives restarts.

The daemon uses Discord's `wait=true` acknowledgement and does not mark failed
sends as delivered. Delivery is still not exactly once: a crash after Discord
accepts a message but before its ID is persisted, or a lost response, can cause
one retry to duplicate a notice. Notifications disable mentions and quote the
original announcement text without machine translation. No real webhook is used
in package tests.
