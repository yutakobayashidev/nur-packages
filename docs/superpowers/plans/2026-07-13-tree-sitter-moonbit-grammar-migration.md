# Tree-sitter MoonBit Grammar Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish `tree-sitter-moonbit-grammar` from `nur-packages` and remove its source input and local derivation from dotnix without changing the Neovim consumer contract.

**Architecture:** `nur-packages` owns a self-contained derivation that fetches the pinned upstream source and exposes the existing parser/query output layout through its default overlay. Dotnix consumes that package through its existing `nur-packages` input and keeps referring to the same `tree-sitter-moonbit-grammar` attribute.

**Tech Stack:** Nix flakes, NUR package overlay, `stdenv.mkDerivation`, Tree-sitter C parser, Home Manager/Neovim package wrapper.

## Global Constraints

- Keep the package attribute name `tree-sitter-moonbit-grammar` unchanged.
- Preserve `$out/parser/moonbit.so` and `$out/queries/moonbit/*.scm`.
- Pin `moonbitlang/tree-sitter-moonbit` at `fe025ee46c206a36aa99f0c8444cb730abe5473e` with `sha256-8udCI1HLGT5uDq7K9X4FcME100OXxoMSejtFl+HFgzY=`.
- Do not add a `tree-sitter-moonbit` flake input to `nur-packages`.
- Publish the `nur-packages` package before updating dotnix's lock file.

---

### Task 1: Publish the grammar from `nur-packages`

**Files:**
- Create: `pkgs/tree-sitter-moonbit-grammar/default.nix`
- Modify: `default.nix`
- Modify: `README.md`

**Interfaces:**
- Consumes: upstream generated `src/parser.c`, `src/scanner.c`, and `queries/*.scm` at revision `fe025ee46c206a36aa99f0c8444cb730abe5473e`.
- Produces: package attribute `tree-sitter-moonbit-grammar`, parser `$out/parser/moonbit.so`, and queries `$out/queries/moonbit/*.scm`.

- [ ] **Step 1: Confirm the package is not exported yet**

Run:

```bash
nix eval --raw .#tree-sitter-moonbit-grammar.pname
```

Expected: FAIL with an error that `tree-sitter-moonbit-grammar` is missing.

- [ ] **Step 2: Add the self-contained derivation**

Create `pkgs/tree-sitter-moonbit-grammar/default.nix`:

```nix
{
  lib,
  stdenv,
  fetchFromGitHub,
  tree-sitter,
}:

stdenv.mkDerivation {
  pname = "tree-sitter-moonbit-grammar";
  version = "0-unstable-2026-07-06";

  src = fetchFromGitHub {
    owner = "moonbitlang";
    repo = "tree-sitter-moonbit";
    rev = "fe025ee46c206a36aa99f0c8444cb730abe5473e";
    hash = "sha256-8udCI1HLGT5uDq7K9X4FcME100OXxoMSejtFl+HFgzY=";
  };

  buildInputs = [ tree-sitter ];

  buildPhase = ''
    runHook preBuild
    cd src
    $CC -shared -fPIC -o parser.so parser.c scanner.c -I .
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/parser $out/queries/moonbit
    cp parser.so $out/parser/moonbit.so
    cp ../queries/*.scm $out/queries/moonbit/
    runHook postInstall
  '';

  meta = {
    description = "Tree-sitter grammar for MoonBit";
    homepage = "https://github.com/moonbitlang/tree-sitter-moonbit";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
}
```

- [ ] **Step 3: Export and document the package**

Add this alphabetically after `tfmv` in `default.nix`:

```nix
  tree-sitter-moonbit-grammar = pkgs.callPackage ./pkgs/tree-sitter-moonbit-grammar { };
```

Add this alphabetically to the package list in `README.md`:

```markdown
- `tree-sitter-moonbit-grammar`
```

- [ ] **Step 4: Format, evaluate, build, and inspect the outputs**

Run:

```bash
nix fmt -- --fail-on-change pkgs/tree-sitter-moonbit-grammar/default.nix default.nix
nix eval --raw .#tree-sitter-moonbit-grammar.pname
nix build .#tree-sitter-moonbit-grammar
test -f result/parser/moonbit.so
test -f result/queries/moonbit/highlights.scm
git diff --check
```

Expected: formatting reports zero changes, evaluation prints `tree-sitter-moonbit-grammar`, build succeeds, both `test` commands succeed, and `git diff --check` exits 0.

- [ ] **Step 5: Commit and publish the package**

```bash
git add README.md default.nix pkgs/tree-sitter-moonbit-grammar/default.nix
git commit -m "feat: package Tree-sitter MoonBit grammar"
git push origin main
```

Expected: the commit succeeds and `origin/main` points to the package commit.

---

### Task 2: Consume the NUR package from dotnix

**Files:**
- Modify: `flake.nix`
- Modify: `flake.lock`
- Modify: `flake-module.nix`
- Modify: `modules/flake/per-system/pkgs.nix`
- Modify: `systems/nixos/common.nix`
- Modify: `systems/darwin/common.nix`
- Modify: `overlays/default.nix`

**Interfaces:**
- Consumes: `inputs.nur-packages.overlays.default` exporting `tree-sitter-moonbit-grammar`.
- Produces: the unchanged `tree-sitter-moonbit-grammar` argument consumed by `modules/flake/features/neovim/package.nix`.

- [ ] **Step 1: Remove the obsolete source input and private source plumbing**

Delete the `tree-sitter-moonbit` input from `flake.nix`:

```nix
    tree-sitter-moonbit = {
      url = "github:moonbitlang/tree-sitter-moonbit";
      flake = false;
    };
```

Delete `_tree-sitter-moonbit = inputs.tree-sitter-moonbit;` and its now-empty overlay wrapper from:

- `modules/flake/per-system/pkgs.nix`
- `systems/nixos/common.nix`
- `systems/darwin/common.nix`

Delete only the `_tree-sitter-moonbit` line from the multi-attribute overlay in `flake-module.nix`.

Delete the complete `tree-sitter-moonbit-grammar = prev.stdenv.mkDerivation { ... };` definition from `overlays/default.nix`.

- [ ] **Step 2: Demonstrate that the old lock still lacks the NUR package**

Run:

```bash
nix eval --raw .#nixosConfigurations.B450M-Pro4.pkgs.tree-sitter-moonbit-grammar.pname
```

Expected: FAIL because the locked `nur-packages` revision predates the new package and the local definition is gone.

- [ ] **Step 3: Update the NUR lock entry**

Run:

```bash
nix flake update nur-packages
```

Expected: `flake.lock` updates `nur-packages` to the published package commit and removes the unreachable `tree-sitter-moonbit` node.

- [ ] **Step 4: Verify the package and all obsolete plumbing**

Run:

```bash
nix eval --raw .#nixosConfigurations.B450M-Pro4.pkgs.tree-sitter-moonbit-grammar.pname
nix build .#nixosConfigurations.B450M-Pro4.pkgs.tree-sitter-moonbit-grammar --no-link
nix eval --raw .#packages.x86_64-linux.neovim.pname
! rg -n '_tree-sitter-moonbit|inputs\.tree-sitter-moonbit|^[[:space:]]*tree-sitter-moonbit =' flake.nix flake-module.nix modules systems overlays
jq -e '(.nodes | has("tree-sitter-moonbit")) | not' flake.lock
rg -n "tree-sitter-moonbit-grammar" modules/flake/features/neovim/package.nix
```

Expected: the package evaluation prints `tree-sitter-moonbit-grammar`, the package builds, the Neovim evaluation prints `neovim`, the negated `rg` and `jq` checks succeed, and the final `rg` shows the unchanged Neovim consumer references.

- [ ] **Step 5: Format and build B450M-Pro4**

Run:

```bash
nix fmt -- --fail-on-change flake.nix flake-module.nix modules/flake/per-system/pkgs.nix systems/nixos/common.nix systems/darwin/common.nix overlays/default.nix
nix build .#nixosConfigurations.B450M-Pro4.config.system.build.toplevel --no-link
git diff --check
```

Expected: formatting reports zero changes, the B450M-Pro4 system toplevel builds successfully, and `git diff --check` exits 0.

- [ ] **Step 6: Check documentation impact, commit, and publish dotnix**

Confirm `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/` need no update because the consumer name and user-facing behavior are unchanged and `CLAUDE.md` already identifies `nur-packages` as the custom-package source of truth.

```bash
git add flake.nix flake.lock flake-module.nix modules/flake/per-system/pkgs.nix systems/nixos/common.nix systems/darwin/common.nix overlays/default.nix
git commit -m "refactor(nix): source MoonBit grammar from NUR"
git push origin main
```

Expected: the commit succeeds and `origin/main` points to the migration commit.
