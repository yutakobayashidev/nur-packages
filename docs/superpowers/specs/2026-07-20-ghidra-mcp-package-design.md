# GhidraMCP Package Design

## Goal

Add GhidraMCP 1.1 to this NUR repository as the `ghidra-mcp` package.

## Package Source and Build

Fetch the official `GhidraMCP-release-1-1.zip` release asset with its fixed
SHA-256 hash. The release archive contains the actual Ghidra extension ZIP, so
the package will use `ghidra.buildGhidraExtension` with building and source
unpacking disabled, then extract the nested extension into
`$out/lib/ghidra/Ghidra/Extensions`.

The package definition will omit unused source-build inputs, commented-out
alternatives, and a custom platform list. The Ghidra extension builder's
platform metadata remains authoritative.

## Repository Integration

Create `pkgs/ghidra-mcp/default.nix`, export it from the repository-level
`default.nix` with `pkgs.callPackage`, and list `ghidra-mcp` alphabetically in
`README.md`. The existing flake and overlay derive their package exports from
`default.nix`, so they require no direct changes.

## Failure Handling

The install phase will fail with a clear error if the outer release archive
does not contain a nested ZIP. Fixed-output hashing prevents an upstream asset
change from being accepted silently.

## Verification

Format the changed Nix files, evaluate the package metadata through the flake,
build `.#ghidra-mcp`, inspect the installed extension tree, and run
`git diff --check`.
