# Compatibility import; new consumers can use the project's flake directly.
let
  source = import ../pkgs/codex-limit-auto-reset/source.nix;
in
{
  imports = [ "${source}/nix/home-manager.nix" ];
}
