# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  bit-vcs = pkgs.callPackage ./pkgs/bit-vcs { };
  archivebox = pkgs.callPackage ./pkgs/archivebox { };
  bumblebee = pkgs.callPackage ./pkgs/bumblebee { };
  continues = pkgs.callPackage ./pkgs/continues { };
  difit = pkgs.callPackage ./pkgs/difit { };
  git-now = pkgs.callPackage ./pkgs/git-now { };
  jj-desc = pkgs.callPackage ./pkgs/jj-desc { };
  keifu = pkgs.callPackage ./pkgs/keifu { };
  opensrc = pkgs.callPackage ./pkgs/opensrc { };
  polycat = pkgs.callPackage ./pkgs/polycat { };
  pretty-ts-errors-markdown = pkgs.callPackage ./pkgs/pretty-ts-errors-markdown { };
  readout = pkgs.callPackage ./pkgs/readout { };
  roots = pkgs.callPackage ./pkgs/roots { };
  similarity-ts = pkgs.callPackage ./pkgs/similarity-ts { };
  symphony = pkgs.callPackage ./pkgs/symphony { };
  tunnelto = pkgs.callPackage ./pkgs/tunnelto { };
  nxapi = pkgs.callPackage ./pkgs/nxapi { };
  waza = pkgs.callPackage ./pkgs/waza { };
}
