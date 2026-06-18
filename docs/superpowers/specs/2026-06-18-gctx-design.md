# gctx Package Design

## Goal

Add `gctx`, a Babashka command-line tool for selecting and activating a named
Google Cloud CLI configuration, to this NUR repository.

## Package Layout

- `pkgs/gctx/gctx.clj` contains the executable Babashka script.
- `pkgs/gctx/default.nix` installs the script as `$out/bin/gctx`.
- The repository root `default.nix` exposes the package as `gctx`.
- `README.md` lists `gctx` with the other packages.

## Runtime Dependencies

The package wraps `gctx` with a `PATH` containing:

- `babashka`
- `fzf`
- `google-cloud-sdk`

This makes the packaged command self-contained with respect to its executable
dependencies while preserving the user's existing Google Cloud CLI
configuration.

## Behavior

- `gctx` lists named Google Cloud CLI configurations as JSON, presents them
  through `fzf`, and activates the selected configuration.
- `gctx --current` prints the active configuration name.
- `gctx --help` prints usage information.
- Canceling `fzf` or selecting no entry does not activate a configuration.
- Failures from `gcloud` are printed to standard error.

## Packaging

Use `stdenvNoCC.mkDerivation` with `makeWrapper`. The install phase copies the
script with executable permissions and wraps it with the runtime dependency
path. This follows the repository's existing derivation style and avoids an
extra launcher script.

The package metadata declares:

- package name and version `gctx` `0.1.0`
- a concise description
- `gctx` as the main program
- Unix platform support

No license is declared because none was provided for the script.

## Verification

Verification consists of:

1. Evaluating the package attribute.
2. Building the `gctx` derivation.
3. Running the built `gctx --help`.
4. Running Babashka tests using `clojure.test` and controlled fake `gcloud`
   and `fzf` commands to verify help output, JSON parsing, current-configuration
   output, and activation without requiring live Google Cloud credentials.
5. Confirming the repository diff only includes the intended package,
   registration, documentation, design, and test-related changes.
