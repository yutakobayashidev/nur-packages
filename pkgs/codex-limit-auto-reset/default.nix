# Compatibility export; the package definition is maintained in the project.
{ pkgs }:
let
  source = import ./source.nix;
in
pkgs.callPackage "${source}/nix/package.nix" { }
