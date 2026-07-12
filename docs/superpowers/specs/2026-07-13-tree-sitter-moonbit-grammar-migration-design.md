# Tree-sitter MoonBit Grammar Migration Design

## Goal

Move `tree-sitter-moonbit-grammar` from dotnix's local overlay into
`yutakobayashidev/nur-packages`, keeping the package name and Neovim consumer
contract unchanged.

## Package ownership

`nur-packages` will own the complete derivation under
`pkgs/tree-sitter-moonbit-grammar/default.nix`. The derivation will fetch a
pinned revision of `moonbitlang/tree-sitter-moonbit` directly with
`fetchFromGitHub`, compile `parser.c` and `scanner.c`, and install the parser and
queries in the same output layout currently consumed by dotnix.

The package will be exported from `default.nix` and therefore from the existing
default NUR overlay. No additional flake input or module will be introduced in
`nur-packages`.

## Dotnix migration

After the NUR package is published, dotnix will update its `nur-packages` lock
entry and remove:

- the `tree-sitter-moonbit` flake input;
- the `_tree-sitter-moonbit` source plumbing from per-system, NixOS, and Darwin
  overlays;
- the local `tree-sitter-moonbit-grammar` derivation.

The Neovim package will continue requesting `tree-sitter-moonbit-grammar` by
name, now supplied by the existing `nur-packages` overlay.

## Verification

In `nur-packages`:

- format and lint the changed Nix files;
- build `tree-sitter-moonbit-grammar` on the local system;
- confirm the parser and query output paths exist.

In dotnix:

- update only the `nur-packages` lock input after removing the obsolete source
  input;
- evaluate the Neovim package;
- build the B450M-Pro4 system toplevel;
- verify the removed input and private overlay attribute no longer occur.

## Rollout

Publish the `nur-packages` commit first. Then update dotnix to consume that
commit, verify it, and publish the dotnix commit to `main`.
