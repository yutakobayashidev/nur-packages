{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
}:
let
  version = "0.2.7";
  sources = {
    aarch64-darwin = {
      name = "acac-darwin-arm64";
      hash = "sha256-s+l/MnGslNLxo8PcfZ/rIR4Tvha5YenHKLMCYJswRlo=";
    };
    aarch64-linux = {
      name = "acac-linux-arm64";
      hash = "sha256-fhmsiykX4rGtmZr1SmWWtcxfnAVUZ5lnqbtjDV27YB0=";
    };
    x86_64-darwin = {
      name = "acac-darwin-x64";
      hash = "sha256-Ime7rtqRQFzn6CqTQr3HVoAI4QPmiIgL7tJVLGfQMYE=";
    };
    x86_64-linux = {
      name = "acac-linux-x64";
      hash = "sha256-Gc+aY0zRgTKP3uuUvtrOJmDnRlSsG/egN2FknZMBhA8=";
    };
  };

  source = sources.${stdenv.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "acac-cli";
  inherit version;

  src = fetchurl {
    url = "https://github.com/RyosukeDTomita/acac-cli/releases/download/v${version}/${source.name}";
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
