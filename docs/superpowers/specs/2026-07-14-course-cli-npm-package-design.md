# Course CLI npm Package for NUR

## Goal

Expose the public Gitea npm package `@yuta/course-cli` through this NUR repository as the `course-cli` package, providing the `nnn` executable.

## Package design

- Add `pkgs/course-cli/default.nix`.
- Fetch version `0.0.1` directly from the public Gitea npm tarball with `fetchurl` and its fixed SHA-256 hash.
- Use the already bundled and minified `dist/nnn.js`; do not fetch the private source repository or resolve npm dependencies during the Nix build.
- Install the bundle under `$out/libexec/course-cli/nnn.js`.
- Create `$out/bin/nnn` with `makeWrapper`, invoking the Bun runtime supplied by Nixpkgs.
- Export the derivation as the NUR attribute `course-cli` and add it to the README package list.
- Omit `meta.license` while the upstream license remains undecided.

## Failure handling

The fixed-output fetch must fail if the published tarball changes without a version and hash update. The build must fail if the expected `dist/nnn.js` is absent. No compatibility fallback or source-build path is included.

## Verification

- Format changed Nix files with `nixfmt`.
- Evaluate the `course-cli` NUR attribute.
- Build `.#course-cli` from a clean Nix derivation.
- Run `result/bin/nnn --help` and confirm the CLI help is displayed.
