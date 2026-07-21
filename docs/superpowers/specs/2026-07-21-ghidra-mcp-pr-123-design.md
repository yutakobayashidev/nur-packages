# GhidraMCP PR 123 Package Replacement Design

## Goal

Replace the packaged GhidraMCP 1.1 pair with a coherent GhidraMCP 1.4
extension and a bridge pinned to the exact head of upstream pull request 123.

## Source Selection

Use the official GhidraMCP 1.4 release archive for the extension. Its release
commit is the base of pull request 123, so the Java extension stays aligned
with the bridge without rebuilding unchanged Java sources.

Pin the bridge to `jethac/GhidraMCP` commit
`f7a030ac4b847eb000126ff574ad5d5ccb0d6eb1`. This is the immutable head of
pull request 123 and includes both commits in the pull request. Fetch the
repository archive with fixed-output hash
`sha256-c79PGVa94kmYu/xi1CHabQuXySZMBkwMQApyau6X7Dg=`.

Fetch the official `GhidraMCP-release-1-4.zip` asset with hash
`sha256-uBylJA/d5X6k6JkXDc2f3ubtKSRigMdCY6UJv8/H5zQ=`.

## Package Design

Keep the existing public package split:

- `ghidra-mcp` installs the Ghidra extension from the official 1.4 archive.
- `ghidra-mcp-bridge` installs `bridge_mcp_ghidra.py` from the pull request
  source and wraps it with its Python runtime.

The extension remains version `1.4`. The bridge uses version
`1.4-unstable-2026-01-11` to identify its 1.4 base and post-release pull
request commit. Replace the bridge runtime dependency on `requests` with
`httpx` and `tenacity`, while retaining `mcp`.

GhidraMCP 1.4 targets Ghidra 11.3.2. Update the historical nixpkgs import to
commit `cff659446eccd532661ea86f0caec4d7f0a8722f`, where Ghidra was updated to
11.3.2, using tarball hash
`sha256-omRUecyvaOtmQuX25CUN7Iwe+9xT/NwLZLmhP7THC6k=`.

## Installation Flow

The extension continues to unpack the nested extension ZIP from the release
archive, clear the invalid descriptive entries from `Module.manifest`, and add
`.dbDirLock` so Nix's immutable store works with Ghidra.

The bridge no longer extracts its script from the release archive. It copies
`bridge_mcp_ghidra.py` directly from the pinned pull request source and wraps
the script with the Python environment. At runtime, MCP requests flow through
the PR bridge to the HTTP endpoint exposed by the 1.4 extension.

## Error Handling and Upstream Scope

Packaging failures must remain explicit: missing release contents or a
missing bridge script fail the build. Runtime HTTP behavior is supplied
unchanged by pull request 123, including its pooled `httpx` client,
connection retry decorators, and configurable decompilation timeout.

The pull request's decompilation docstring says the maximum is 600 seconds,
while its implementation clamps at 1800 seconds. Do not carry a downstream
behavior patch; package the requested pull request exactly and leave that
upstream inconsistency unchanged.

## Documentation

Update `README.md` to state that the extension is 1.4, targets Ghidra 11.3.2,
and that the bridge is pinned to pull request 123. The historical 1.1 design
and implementation plan remain unchanged as records of the earlier package
addition.

## Verification

Verify all of the following:

1. Nix formatting and evaluation succeed, reporting extension 1.4, bridge
   `1.4-unstable-2026-01-11`, and Ghidra 11.3.2.
2. Both `ghidra-mcp` and `ghidra-mcp-bridge` build successfully.
3. The installed bridge imports `httpx` and `tenacity`, contains the pinned
   PR timeout implementation, and starts successfully enough to expose MCP
   help without an import error.
4. The extension composes with its passthrough Ghidra derivation and the
   installed extension tree has the expected manifest and lock-file fixups.
5. `git diff --check` and the repository's Nix CI evaluation pass.
