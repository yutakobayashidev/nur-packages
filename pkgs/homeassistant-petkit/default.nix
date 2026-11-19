# Build all dependencies with the interpreter used by the consuming HA package.
{
  pkgs,
  python3Packages ? pkgs.home-assistant.python3Packages,
}:
let
  pypetkitapi = python3Packages.callPackage ./pypetkitapi.nix { };
  sdp-transform = python3Packages.callPackage ./sdp-transform.nix { };
in
python3Packages.callPackage ./petkit.nix {
  inherit (pkgs) buildHomeAssistantComponent;
  inherit pypetkitapi sdp-transform;
}
