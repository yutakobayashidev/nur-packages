# Research and Oura MCP packages

These packages provide local stdio MCP executables. Source commits and npm
dependencies are pinned; starting a server does not run `npx` or install packages.
Each package exposes `meta.mainProgram`, so `lib.getExe` works with
`mcp-servers-nix.settings.servers`.

| NUR attribute / executable | Upstream |
| --- | --- |
| `clinicaltrialsgov-mcp-server` | [cyanheads/clinicaltrialsgov-mcp-server](https://github.com/cyanheads/clinicaltrialsgov-mcp-server) |
| `crossref-mcp-server` | [cyanheads/crossref-mcp-server](https://github.com/cyanheads/crossref-mcp-server) |
| `openalex-mcp-server` | [cyanheads/openalex-mcp-server](https://github.com/cyanheads/openalex-mcp-server) |
| `pubmed-mcp-server` | [cyanheads/pubmed-mcp-server](https://github.com/cyanheads/pubmed-mcp-server) |
| `semanticscholar-mcp` | [xbghc/semanticscholar-mcp](https://github.com/xbghc/semanticscholar-mcp) |
| `unpaywall-mcp` | [ElliotPadfield/unpaywall-mcp](https://github.com/ElliotPadfield/unpaywall-mcp) |
| `elsevier-mcp` | [kemalabuteliyte/elsevier-mcp](https://github.com/kemalabuteliyte/elsevier-mcp) |
| `oura-mcp-server` | [trenerok/oura-mcp-server](https://github.com/trenerok/oura-mcp-server) |

## Use with mcp-servers-nix

With this repository's overlay applied to `pkgs`:

```nix
{ lib, pkgs, ... }:
{
  mcp-servers.settings.servers = {
    pubmed = {
      command = lib.getExe pkgs.pubmed-mcp-server;
      env.MCP_TRANSPORT_TYPE = "stdio";
    };
    semantic-scholar.command = lib.getExe pkgs.semanticscholar-mcp;
  };
}
```

The four cyanheads servers accept `MCP_TRANSPORT_TYPE=stdio`; set it explicitly
in clients. The other four upstream entry points use stdio directly. Supply
API credentials at runtime through the client's secret handling, not Nix literals.
Elsevier requires `ELSEVIER_API_KEY` at startup and optionally accepts
`ELSEVIER_INST_TOKEN`. Oura accepts `OURA_ACCESS_TOKEN` and the upstream OAuth
refresh settings. Unpaywall needs `UNPAYWALL_EMAIL` or a per-call email for DOI
lookups; Semantic Scholar optionally accepts `SEMANTIC_SCHOLAR_API_KEY`.
See each upstream README for service-specific configuration and access limits.

Packages do not enable MCP clients, create accounts, or configure credentials.

## Build and verification

```sh
nix build .#pubmed-mcp-server
```

Every package runs `tests/mcp-stdio.py` during its install check. The test starts
the installed executable from an empty working directory, performs MCP
`initialize` and `tools/list`, and requires valid JSON-RPC on stdout and a
nonempty tool catalog. Dummy credentials satisfy startup validation where
needed. The test does not invoke tools or access provider APIs; successful
packaging does not verify authenticated queries.

## Updating

Update the source revision/hash and `npmDepsHash` together. The four cyanheads
projects ship Bun locks; their package directories include npm locks generated
from the pinned upstream `package.json` with Node 24's
`npm install --registry=https://registry.npmjs.org --package-lock-only --ignore-scripts --no-audit --no-fund`.
Those committed locks define the Nix dependency graph independently of Bun's
lock. Builds run the upstream TypeScript compiler and alias-resolution steps
using Nixpkgs TypeScript compilers built from source, without requiring Bun at
runtime. All eight builds remove upstream `dist/` output and compile TypeScript
afresh. npm lifecycle scripts are disabled; the unused Elsevier distribution
bundle is not built, so its prebuilt npm esbuild binary is not executed.
The cyanheads packages omit optional framework peers from the runtime closure;
these include test tooling and prebuilt native addons. Direct server dependencies
remain installed. npm libraries still use their pinned registry distributions;
this is not a source rebuild of every transitive JavaScript library. Regenerate those locks when updating sources,
review dependency changes, and build all affected packages.
