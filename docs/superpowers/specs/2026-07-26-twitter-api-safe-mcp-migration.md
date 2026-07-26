# Twitter API Safe MCP Migration

## Goal

Replace the standalone `nakasyou/twitter_api_safe_relay_mcp` package with the
MCP package maintained in `fa0311/twitter_api_safe_relay`.

## Design

- Rename the public Nix attribute and package directory to
  `twitter-api-safe-mcp`, matching upstream.
- Build the `twitter-api-safe-mcp` workspace and its local dependencies from
  upstream commit `0026d9d6a879a5ac263db8ba3563fd09e4f6aa10`, which contains package
  version `0.1.1`.
- Use upstream's `pnpm-lock.yaml` with pnpm 11 instead of maintaining a
  generated npm lockfile.
- Install the production MCP workspace and expose its upstream executable name,
  `twitter-api-safe-mcp`.
- Do not retain an alias or compatibility wrapper for the old
  `twitter-api-safe-relay-mcp` name.

## Runtime Contract

MCP clients launch `twitter-api-safe-mcp` with a relay settings JSON file as
its positional argument. The settings choose stdio or HTTP transport and define
the Playwright browser profiles used for Twitter/X requests. Stdio clients must
set `"mcp": { "transport": "stdio" }`; the upstream default is HTTP.

## NixOS Module

The flake exports `nixosModules.twitter-api-safe-mcp`. Enabling
`services.twitter-api-safe-mcp` generates the upstream JSON settings file and
runs the package as `twitter-api-safe-mcp.service`.

The module owns only the native process lifecycle and settings generation.
Browser containers, CDP proxies, reverse proxies, and tunnel clients remain
host-specific and can extend the generated systemd unit with ordering
dependencies. The default settings bind to `127.0.0.1:3000` and enable the
dashboard and HTTP MCP transport. Enabling the service requires at least one
browser profile, and the unit always restarts so a clean process exit after a
browser disconnect does not leave the relay offline.

## Verification

Evaluate the package metadata, build it in the flake, inspect the installed
workspace and executable, confirm that invoking the executable without a
settings file reports the upstream usage error, and evaluate the generated
NixOS service and JSON settings.
