{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  inherit (stdenvNoCC.hostPlatform) system;
  version = "6.9.18";
  assets = {
    "x86_64-linux" = {
      target = "linux_amd64";
      hash = "sha256-EPlBtZ6OteGmf/U5mOH0mpKattUQhExGruZF4rJGJoU=";
    };
    "aarch64-linux" = {
      target = "linux_arm64";
      hash = "sha256-2XlFFPJV31QJTxL/ZN92AXwnVt6gkc7YN7L3Hzw+v2s=";
    };
    "x86_64-darwin" = {
      target = "darwin_amd64";
      hash = "sha256-t0I2+xU4n6SJGV0Zf1QIY4/Ypkw0dcJ/1LV8VCevQbA=";
    };
    "aarch64-darwin" = {
      target = "darwin_arm64";
      hash = "sha256-gKdTu0jPgvutTTN1XggSbLeZaIW8N5a8eBXIDOgU7eU=";
    };
  };
  asset = assets.${system} or (throw "unsupported platform for cliproxyapi: ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "cliproxyapi";
  inherit version;

  src = fetchurl {
    url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${version}/CLIProxyAPI_${version}_${asset.target}.tar.gz";
    inherit (asset) hash;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 cli-proxy-api "$out/bin/cli-proxy-api"
    runHook postInstall
  '';

  meta = with lib; {
    description = "AI CLI proxy service providing OpenAI/Gemini/Claude compatible API";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    license = licenses.mit;
    mainProgram = "cli-proxy-api";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
