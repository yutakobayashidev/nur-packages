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

let
  jportaudio = pkgs.callPackage ./pkgs/jportaudio { };
in
{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  agent-scan = pkgs.callPackage ./pkgs/agent-scan { };
  beatoraja = pkgs.callPackage ./pkgs/beatoraja { inherit jportaudio; };
  before-and-after = pkgs.callPackage ./pkgs/before-and-after { };
  bit-vcs = pkgs.callPackage ./pkgs/bit-vcs { };
  bumblebee = pkgs.callPackage ./pkgs/bumblebee { };
  continues = pkgs.callPackage ./pkgs/continues { };
  defuddle = pkgs.callPackage ./pkgs/defuddle { };
  difit = pkgs.callPackage ./pkgs/difit { };
  fennel-ls = pkgs.callPackage ./pkgs/fennel-ls { };
  gctx = pkgs.callPackage ./pkgs/gctx { };
  git-now = pkgs.callPackage ./pkgs/git-now { };
  ghtkn = pkgs.callPackage ./pkgs/ghtkn { };
  hermes = pkgs.callPackage ./pkgs/hermes { };
  headroom-ai = pkgs.callPackage ./pkgs/headroom-ai { };
  jj-desc = pkgs.callPackage ./pkgs/jj-desc { };
  inherit jportaudio;
  keifu = pkgs.callPackage ./pkgs/keifu { };
  opensrc = pkgs.callPackage ./pkgs/opensrc { };
  polycat = pkgs.callPackage ./pkgs/polycat { };
  pretty-ts-errors-markdown = pkgs.callPackage ./pkgs/pretty-ts-errors-markdown { };
  pyproject-build-systems = pkgs.callPackage ./pkgs/pyproject-build-systems { };
  pyproject-nix = pkgs.callPackage ./pkgs/pyproject-nix { };
  readout = pkgs.callPackage ./pkgs/readout { };
  tfmv = pkgs.callPackage ./pkgs/tfmv { };
  roots = pkgs.callPackage ./pkgs/roots { };
  s3s = pkgs.callPackage ./pkgs/s3s { };
  similarity-ts = pkgs.callPackage ./pkgs/similarity-ts { };
  skill-scanner = pkgs.callPackage ./pkgs/skill-scanner { };
  skillspector = pkgs.callPackage ./pkgs/skillspector { };
  symphony = pkgs.callPackage ./pkgs/symphony { };
  tunnelto = pkgs.callPackage ./pkgs/tunnelto { };
  nxapi = pkgs.callPackage ./pkgs/nxapi { };
  uv2nix = pkgs.callPackage ./pkgs/uv2nix { };
  pike = pkgs.callPackage ./pkgs/pike { };
  whichllm = pkgs.callPackage ./pkgs/whichllm { };
  waza = pkgs.callPackage ./pkgs/waza { };
}
