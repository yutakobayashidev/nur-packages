{
  buildFHSEnv,
  fetchurl,
  lib,
  stdenv,
  stdenvNoCC,
}:

let
  version = "0.6.2";
  sources = {
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-K9NwQ6TthjYh7cWeKKqmUugZPlWryg6Ud/Wurhxl1ik=";
    };
    x86_64-linux = {
      arch = "x64";
      hash = "sha256-qIHh0ryR4xIYslFxZkTsX40WHVzLMOfqtmzyumQQUR0=";
    };
  };
  source = sources.${stdenv.hostPlatform.system};
  beeper-cli-unwrapped = stdenvNoCC.mkDerivation {
    pname = "beeper-cli-unwrapped";
    inherit version;

    src = fetchurl {
      url = "https://github.com/beeper/cli/releases/download/v${version}/beeper-cli-${version}-linux-${source.arch}.tar.gz";
      inherit (source) hash;
    };

    sourceRoot = ".";
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 bin/beeper "$out/bin/beeper"

      runHook postInstall
    '';
  };
in
buildFHSEnv {
  name = "beeper-cli";
  runScript = "${beeper-cli-unwrapped}/bin/beeper";
  targetPkgs = pkgs: [ pkgs.glibc ];

  meta = {
    description = "Official CLI for Beeper Desktop and Beeper Server";
    homepage = "https://github.com/beeper/cli";
    license = lib.licenses.mit;
    mainProgram = "beeper-cli";
    platforms = builtins.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
