# Course CLI npm Package Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `@yuta/course-cli@0.0.1` to this NUR repository as the `course-cli` package with the `nnn` executable.

**Architecture:** Fetch the public, dependency-bundled Gitea npm tarball as a fixed-output source. Install its single JavaScript bundle and wrap the Nixpkgs Bun runtime, without rebuilding the private source or resolving npm dependencies.

**Tech Stack:** Nix, Nixpkgs `stdenvNoCC`, `fetchurl`, `makeWrapper`, Bun

## Global Constraints

- NUR attribute: `course-cli`.
- Executable: `nnn`.
- Upstream version: `0.0.1`.
- Source: public Gitea npm tarball only.
- Tarball hash: `sha256-laOrThwJ0KazKDL9buL0V/ORr3aDODb1w+m2oJ+iuEQ=`.
- Do not resolve npm dependencies or fetch the private source repository.
- Omit `meta.license` while the upstream license is undecided.
- Create only one commit after all implementation and verification steps pass.

---

### Task 1: Add and verify the NUR package

**Files:**
- Create: `pkgs/course-cli/default.nix`
- Modify: `default.nix`
- Modify: `README.md`

**Interfaces:**
- Consumes: Gitea npm tarball containing `package/dist/nnn.js`.
- Produces: NUR derivation `course-cli` and executable `$out/bin/nnn`.

- [ ] **Step 1: Add the package derivation**

Create `pkgs/course-cli/default.nix`:

```nix
{
  lib,
  stdenvNoCC,
  fetchurl,
  bun,
  makeWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "course-cli";
  version = "0.0.1";

  src = fetchurl {
    url = "https://git.yutakobayashi.com/api/packages/yuta/npm/%40yuta%2Fcourse-cli/-/${finalAttrs.version}/course-cli-${finalAttrs.version}.tgz";
    hash = "sha256-laOrThwJ0KazKDL9buL0V/ORr3aDODb1w+m2oJ+iuEQ=";
  };

  sourceRoot = "package";
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm644 dist/nnn.js $out/libexec/${finalAttrs.pname}/nnn.js
    makeWrapper ${bun}/bin/bun $out/bin/nnn \
      --add-flags $out/libexec/${finalAttrs.pname}/nnn.js

    runHook postInstall
  '';

  meta = {
    description = "Course API CLI";
    homepage = "https://git.yutakobayashi.com/yuta/-/packages/npm/%40yuta%2Fcourse-cli/0.0.1";
    mainProgram = "nnn";
    platforms = lib.platforms.unix;
  };
})
```

- [ ] **Step 2: Export the package**

Add this entry to the package attributes in `default.nix`:

```nix
  course-cli = pkgs.callPackage ./pkgs/course-cli { };
```

- [ ] **Step 3: Document the package**

Add `course-cli` to the alphabetized package list in `README.md`:

```markdown
- `course-cli`
```

- [ ] **Step 4: Format and evaluate**

Run:

```sh
nix run nixpkgs#nixfmt -- pkgs/course-cli/default.nix default.nix
nix eval .#course-cli.meta.mainProgram --raw
```

Expected evaluation output:

```text
nnn
```

- [ ] **Step 5: Build and smoke-test**

Run:

```sh
nix build .#course-cli
./result/bin/nnn --help
```

Expected help output begins with:

```text
Usage: nnn [options] [command]
```

- [ ] **Step 6: Review documentation impact and commit the final output**

Confirm `README.md` reflects the new package and no agent-facing or module documentation requires changes. Then run:

```sh
git diff --check
git status --short
git add pkgs/course-cli/default.nix default.nix README.md docs/superpowers/specs/2026-07-14-course-cli-npm-package-design.md docs/superpowers/plans/2026-07-14-course-cli-npm-package.md
git commit -m "feat: package course-cli"
```
