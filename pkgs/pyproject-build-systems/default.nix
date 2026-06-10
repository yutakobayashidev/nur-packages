{
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "pyproject-build-systems";
  version = "0-unstable-2026-06-11";

  src = fetchFromGitHub {
    owner = "pyproject-nix";
    repo = "build-system-pkgs";
    rev = "7bff980f37fc24e09dbc986643719900c139bf12";
    hash = "sha256-MbXylBTkWqVm8/VYjoULtMoVRgWBN1gSHbeRKsOsPlU=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/pyproject-build-systems"
    cp -R . "$out/pyproject-build-systems/"
    runHook postInstall
  '';
}
