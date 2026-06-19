{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:
let
  inherit (stdenv.hostPlatform) system;
  version = "0.5.11";
  asset =
    {
      x86_64-linux = "linux-x86_64";
      aarch64-darwin = "macos-arm64";
      x86_64-darwin = "macos-x86_64";
    }
    .${system} or (throw "agent-scan: unsupported system ${system}");
  hash =
    {
      x86_64-linux = "sha256-jkZhcNva17h7XosFkHy8GexatzanNlk4EsF9ckxUISk=";
      aarch64-darwin = "sha256-36tJCrnhyTExE8xSkQv3wMgFeICIkNFgPo62hsZtKFI=";
      x86_64-darwin = "sha256-DbOlz7n+ksJjJRN8/r5VOekCNTs4Rgq1yeE9piSm8SQ=";
    }
    .${system};
in
stdenv.mkDerivation {
  pname = "agent-scan";
  inherit version;

  src = fetchurl {
    url = "https://github.com/snyk/agent-scan/releases/download/v${version}/agent-scan-${version}-${asset}";
    inherit hash;
  };

  dontUnpack = true;
  dontStrip = true;

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.isLinux [
    stdenv.cc.cc.lib
    zlib
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/snyk-agent-scan
    runHook postInstall
  '';

  meta = with lib; {
    description = "Snyk security scanner for AI agent components (MCP servers, skills, tools)";
    homepage = "https://github.com/snyk/agent-scan";
    license = licenses.asl20;
    mainProgram = "snyk-agent-scan";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
