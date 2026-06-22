{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
}:
let
  sources = {
    aarch64-darwin = {
      name = "acac-darwin-arm64";
      hash = "sha256-u6W7cgEsVlrRyBdVVhDKtmcBhIfzmEogrh4RqnzPsZo=";
    };
    aarch64-linux = {
      name = "acac-linux-arm64";
      hash = "sha256-lHUM+TNQJ0G+BCRoAJJQ+cFa4DibCCw7TZDq8M9gEv8=";
    };
    x86_64-darwin = {
      name = "acac-darwin-x64";
      hash = "sha256-ibVrz67oI3ywhhzLh+aGFOqGldhR+Fmf1ZSGQL6kXV0=";
    };
    x86_64-linux = {
      name = "acac-linux-x64";
      hash = "sha256-dTcQT7hy1CDUKE9QdI41O/s+Fj9GCk/Ri4xHJCR80/Q=";
    };
  };

  source = sources.${stdenv.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "acac-cli";
  version = "0.2.1";

  src = fetchurl {
    url = "https://github.com/RyosukeDTomita/acac-cli/releases/download/v0.2.1/${source.name}";
    inherit (source) hash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/acac"

    runHook postInstall
  '';

  meta = {
    description = "AtCoder AC counter CLI";
    homepage = "https://github.com/RyosukeDTomita/acac-cli";
    license = lib.licenses.mit;
    mainProgram = "acac";
    platforms = builtins.attrNames sources;
  };
}
