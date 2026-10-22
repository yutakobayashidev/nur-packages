{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "1.3.4";
  sources = {
    aarch64-darwin = {
      name = "Darwin_arm64";
      hash = "sha256-cJf4sST6DoKlZhC2ePGfc/Dzg/Q76nyNyRuQrBOJUYE=";
    };
    aarch64-linux = {
      name = "Linux_arm64";
      hash = "sha256-axdRmm17oBLBd7UJHflgrL9ZvxSxArBViqbZ9l62av4=";
    };
    x86_64-darwin = {
      name = "Darwin_x86_64";
      hash = "sha256-txmhVOQuA/jwlVtykg3nbZjPrVq1uSOBnX0bFmkr988=";
    };
    x86_64-linux = {
      name = "Linux_x86_64";
      hash = "sha256-kwuT5J1GZkuHIPvas9FnBWQbqMDCMrL3K3Oc5jX1fkM=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "xurl";
  inherit version;

  src = fetchurl {
    url = "https://github.com/xdevplatform/xurl/releases/download/v${version}/xurl_${source.name}.tar.gz";
    inherit (source) hash;
  };

  sourceRoot = ".";
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 xurl "$out/bin/xurl"

    runHook postInstall
  '';

  meta = {
    description = "Official CLI for the X API";
    homepage = "https://github.com/xdevplatform/xurl";
    license = lib.licenses.mit;
    mainProgram = "xurl";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
