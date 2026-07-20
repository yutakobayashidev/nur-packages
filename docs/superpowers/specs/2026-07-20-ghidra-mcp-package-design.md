# GhidraMCP Package Design

## Goal

Add GhidraMCP 1.1 to this NUR repository as the `ghidra-mcp` package.

## Package Source and Build

Fetch the official `GhidraMCP-release-1-1.zip` release asset with its fixed
SHA-256 hash. The release archive and upstream Maven metadata target Ghidra
11.3.1, while the repository's current nixpkgs provides Ghidra 12.0.4. Pin the
nixpkgs revision that packaged Ghidra 11.3.1 with a fixed tarball hash and use
that package set to call the GhidraMCP expression. This keeps NUR, standalone
overlay, and flake evaluation on the same compatible extension builder.

The release archive contains the actual Ghidra extension ZIP, so the package
will use the pinned `ghidra.buildGhidraExtension` with building and source
unpacking disabled, then extract the nested extension into
`$out/lib/ghidra/Ghidra/Extensions`. The release's `Module.manifest` contains
name and description assignments that Ghidra rejects; clear it because those
values are already defined in `extension.properties` and the manifest contains
no module file license declarations. Expose the compatible Ghidra derivation
as `ghidra-mcp.ghidra` so consumers can compose the extension without
accidentally using Ghidra 12.

The package definition will omit unused source-build inputs, commented-out
alternatives, and a custom platform list. The Ghidra extension builder's
platform metadata remains authoritative.

## Repository Integration

Create `pkgs/ghidra-mcp/default.nix`, instantiate it from the pinned historical
package set in the repository-level `default.nix`, and list `ghidra-mcp`
alphabetically in `README.md` with a compatible composition example. The
existing flake and overlay derive their package exports from `default.nix`, so
they require no direct changes or flake-only input.

## Failure Handling

The install phase will fail with a clear error if the outer release archive
does not contain a nested ZIP. Fixed-output hashes prevent either the upstream
extension asset or the historical nixpkgs source from changing silently.

## Verification

Format the changed Nix files, evaluate both the extension version and its
passthru Ghidra version through the flake, build `.#ghidra-mcp`, build the
extension composed with `ghidra-mcp.ghidra`, inspect the installed extension
tree, run the composed package's headless analyzer and confirm it reports no
module manifest error, and run `git diff --check`.
