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

## Verification

Evaluate the package metadata, build it in the flake, inspect the installed
workspace and executable, and confirm that invoking the executable without a
settings file reports the upstream usage error.
