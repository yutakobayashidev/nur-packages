{
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "pyproject-nix";
  version = "0-unstable-2026-06-11";

  src = fetchFromGitHub {
    owner = "pyproject-nix";
    repo = "pyproject.nix";
    rev = "ad83f1ead0e78e57b188f35cb57298affb06fc5f";
    hash = "sha256-rRK3IFixgsrK6S3e14Xz9HAZm7+kMAIl3oi5zZlcwYI=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/pyproject-nix"
    cp -R . "$out/pyproject-nix/"
    runHook postInstall
  '';
}
