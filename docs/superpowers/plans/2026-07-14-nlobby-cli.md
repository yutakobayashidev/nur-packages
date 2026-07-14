# N Lobby CLI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `nlobby-cli` version `1.6.0` to this NUR repository with working CLI, MCP, and browser authentication runtime support.

**Architecture:** Build the tagged GitHub source with upstream's pnpm lockfile and Nixpkgs' offline pnpm dependency hook. Install the production dependency closure and wrap Node.js, setting Nixpkgs Chromium for Puppeteer on Linux.

**Tech Stack:** Nix, Node.js, pnpm, `fetchPnpmDeps`, Puppeteer, Chromium

## Global Constraints

- Work only on branch `feature/nlobby-cli`.
- Package attribute and pname: `nlobby-cli`.
- Version and source revision: `1.6.0` / `v1.6.0`.
- Provide `nlobby` and `nlobby-mcp`; set `meta.mainProgram = "nlobby"`.
- Do not generate a downstream npm lockfile or download browsers during the build.
- Create one final commit after verification.

---

### Task 1: Add and verify nlobby-cli

**Files:**
- Create: `pkgs/nlobby-cli/default.nix`
- Modify: `default.nix`
- Modify: `README.md`

**Interfaces:**
- Consumes: GitHub tag `v1.6.0`, `pnpm-lock.yaml`, Nixpkgs Node.js and Chromium.
- Produces: `nlobby-cli`, `$out/bin/nlobby`, and `$out/bin/nlobby-mcp`.

- [ ] **Step 1: Add the derivation with a bootstrap pnpm hash**

Use `fetchFromGitHub`, `fetchPnpmDeps`, `pnpm_10`, and `pnpmConfigHook`. Set the source hash to `sha256-OFogs/BcFg+e/n6O/wCOGX4fJv/XT+heVQ+EJdeuTzI=` and initially use `lib.fakeHash` for `pnpmDeps` so Nix reports the correct dependency hash.

- [ ] **Step 2: Export and document the package**

Add `nlobby-cli = pkgs.callPackage ./pkgs/nlobby-cli { };` to `default.nix` and add `nlobby-cli` to the README package list.

- [ ] **Step 3: Resolve the pnpm fixed-output hash**

Stage the new source for flake evaluation and run `nix build .#nlobby-cli`. Replace `lib.fakeHash` with the reported `sha256-...` value, then rebuild.

- [ ] **Step 4: Verify the package interface**

Run `nix eval .#nlobby-cli.meta.mainProgram --raw`, `result/bin/nlobby --help`, `result/bin/nlobby-mcp --help`, and `nix run .#nlobby-cli -- --help`. Confirm the first evaluation prints `nlobby` and each command displays CLI help.

- [ ] **Step 5: Verify browser runtime wiring**

On Linux, inspect `$out/bin/nlobby` and confirm `PUPPETEER_EXECUTABLE_PATH` points to the Nixpkgs Chromium executable. Run `nlobby login` only far enough to confirm Chromium launches, then terminate without submitting credentials.

- [ ] **Step 6: Final review and commit**

Run the Nix formatter, `git diff --check`, inspect the staged diff, rebuild with `--rebuild`, and create one commit named `feat: package nlobby-cli`.
