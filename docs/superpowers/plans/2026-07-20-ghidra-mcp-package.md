# GhidraMCP Package Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish GhidraMCP 1.1 from this NUR repository as `ghidra-mcp`.

**Architecture:** Import the fixed nixpkgs revision containing Ghidra 11.3.1 from `default.nix`, use its package set to instantiate one extension derivation from the official nested release archive, and expose the compatible Ghidra runtime through package passthru. This keeps NUR, standalone overlay, and flake consumers on the same builder without a flake-only dependency path.

**Tech Stack:** Nix, `ghidra.buildGhidraExtension`, GitHub release assets

## Global Constraints

- The public package attribute is `ghidra-mcp`.
- Package version is `1.1`.
- Use the official `GhidraMCP-release-1-1.zip` asset and fixed hash `sha256-WHwlwo8sV7t9irFKg0gOOzL04wvfhf+WElRVa9lAnus=`.
- Use nixpkgs revision `8d94befdfd62a53f99adb09b1b62b5af9c143c6e` and fixed tarball hash `sha256-aCeZlH1DQ/4rzVUI/uiDCPBiC3xjdZqycIIzl5xdPPg=` for Ghidra 11.3.1.
- Do not add source-build fallbacks, compatibility shims, or custom platform metadata.

---

### Task 1: Add and publish the GhidraMCP extension

**Files:**
- Create: `pkgs/ghidra-mcp/default.nix`
- Modify: `default.nix`
- Modify: `README.md`

**Interfaces:**
- Consumes: `ghidra.buildGhidraExtension`, `fetchurl`, and the existing repository package export convention.
- Produces: the `ghidra-mcp` derivation in `legacyPackages` and `packages` for supported systems.

- [ ] **Step 1: Verify the package is not exported yet**

Run:

```bash
nix eval --raw .#ghidra-mcp.pname
```

Expected: evaluation fails because `ghidra-mcp` does not exist.

- [ ] **Step 2: Create the package definition**

Create `pkgs/ghidra-mcp/default.nix`:

```nix
{
  lib,
  fetchurl,
  ghidra,
}:

ghidra.buildGhidraExtension rec {
  pname = "GhidraMCP";
  version = "1.1";

  src = fetchurl {
    url = "https://github.com/LaurieWired/GhidraMCP/releases/download/${version}/GhidraMCP-release-1-1.zip";
    hash = "sha256-WHwlwo8sV7t9irFKg0gOOzL04wvfhf+WElRVa9lAnus=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$TMPDIR/extract" "$out/lib/ghidra/Ghidra/Extensions"
    unzip -q "$src" -d "$TMPDIR/extract"

    extensionZip="$(find "$TMPDIR/extract" -type f -name '*.zip' -print -quit)"
    if [ -z "$extensionZip" ]; then
      echo "Error: release archive contains no Ghidra extension ZIP" >&2
      exit 1
    fi

    unzip -q "$extensionZip" -d "$out/lib/ghidra/Ghidra/Extensions"
    for extension in "$out/lib/ghidra/Ghidra/Extensions"/*; do
      : > "$extension/Module.manifest"
      touch "$extension/.dbDirLock"
    done

    runHook postInstall
  '';

  passthru = { inherit ghidra; };

  meta = {
    description = "MCP server for Ghidra that enables LLM-assisted reverse engineering";
    homepage = "https://github.com/LaurieWired/GhidraMCP";
    license = lib.licenses.mit;
  };
}
```

- [ ] **Step 3: Export the package**

Add the historical package set to the top-level `let` in `default.nix`:

```nix
  ghidraPkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/8d94befdfd62a53f99adb09b1b62b5af9c143c6e.tar.gz";
    sha256 = "sha256-aCeZlH1DQ/4rzVUI/uiDCPBiC3xjdZqycIIzl5xdPPg=";
  }) {
    system = pkgs.stdenv.hostPlatform.system;
  };
```

Add the following entry to the alphabetized package set, after `gh-actions-language-server`:

```nix
  ghidra-mcp = ghidraPkgs.callPackage ./pkgs/ghidra-mcp { };
```

- [ ] **Step 4: Document the package**

Add this entry to the alphabetized package list in `README.md`, after `gh-actions-language-server`:

```markdown
- `ghidra-mcp`
```

Document that release 1.1 targets Ghidra 11.3.1 and show compatible composition:

```nix
let
  extension = pkgs.ghidra-mcp;
in
extension.ghidra.withExtensions (_: [ extension ])
```

- [ ] **Step 5: Format and evaluate**

Run:

```bash
nix run nixpkgs#nixfmt -- pkgs/ghidra-mcp/default.nix default.nix
nix eval --raw .#ghidra-mcp.pname
nix eval --raw .#ghidra-mcp.ghidra.version
```

Expected: formatting exits successfully and evaluation prints `GhidraMCP` and `11.3.1`.

- [ ] **Step 6: Build and inspect the extension**

Run:

```bash
nix build .#ghidra-mcp
find -L result/lib/ghidra/Ghidra/Extensions -maxdepth 3 -type f -print
nix build --impure --expr 'let flake = builtins.getFlake (toString ./.); extension = flake.packages.${builtins.currentSystem}.ghidra-mcp; in extension.ghidra.withExtensions (_: [ extension ])'
result/bin/ghidra-analyzeHeadless 2>&1 | head
```

Expected: both builds exit successfully, the installed extension tree contains GhidraMCP files plus `.dbDirLock`, and the headless analyzer reports usage without a module manifest error.

- [ ] **Step 7: Check the final diff and documentation impact**

Run:

```bash
git diff --check
git status --short
git diff -- README.md default.nix pkgs/ghidra-mcp/default.nix
```

Expected: no whitespace errors; only the package definition, export, and README package list are implementation changes. `AGENTS.md`, `CLAUDE.md`, and other documentation need no update because commands, architecture, and agent instructions are unchanged.

- [ ] **Step 8: Commit the package**

```bash
git add README.md default.nix pkgs/ghidra-mcp/default.nix
git commit -m "feat: add ghidra-mcp"
```
