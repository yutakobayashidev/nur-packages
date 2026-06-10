{
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "uv2nix";
  version = "0-unstable-2026-06-11";

  src = fetchFromGitHub {
    owner = "pyproject-nix";
    repo = "uv2nix";
    rev = "0497ccef038da091002be7c05263a7f27820974f";
    hash = "sha256-yZVQNvmDx1SFjvlwevywsXWJnieSRqmQr7/fCTMyyd0=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/uv2nix"
    cp -R . "$out/uv2nix/"
    runHook postInstall
  '';
}
