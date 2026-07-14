# N Lobby CLI NUR Package Design

## Goal

Expose `minagishl/nlobby-cli` through this NUR repository as package `nlobby-cli`, providing both `nlobby` and `nlobby-mcp`.

## Packaging decision

Build the public `v1.6.0` GitHub source with its committed `pnpm-lock.yaml` using `fetchPnpmDeps` and `pnpmConfigHook`. The npm tarball cannot be wrapped directly because its minified bundle intentionally externalizes all runtime dependencies and does not contain a lockfile or `node_modules`. Generating a new npm lockfile downstream would duplicate upstream dependency resolution and reduce reproducibility.

Install the pruned production dependency tree beside `dist/index.js` and wrap Nixpkgs Node.js. On Linux, include Nixpkgs Chromium and set `PUPPETEER_EXECUTABLE_PATH`; on Darwin, preserve upstream discovery of the system Chrome installation. Browser downloads and package lifecycle scripts remain disabled during the Nix build.

## Package interface

- NUR attribute: `nlobby-cli`.
- Main executable: `nlobby`.
- MCP alias: `nlobby-mcp`.
- Supported platforms: Unix.
- License: MIT.

## Verification

Format and evaluate the derivation, build it without network access, run both executables' help paths, verify `nix run .#nlobby-cli`, and on Linux confirm the wrapper points Puppeteer at the Nixpkgs Chromium executable.
