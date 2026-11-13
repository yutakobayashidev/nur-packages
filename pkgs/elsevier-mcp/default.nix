{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  python3,
  typescript_5,
}:

(buildNpmPackage.override { nodejs = nodejs_24; }) {
  pname = "elsevier-mcp";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "kemalabuteliyte";
    repo = "elsevier-mcp";
    rev = "59fbbe899bab421d4100dcd1fe542b5901ab0b66";
    hash = "sha256-XZEapBuyV/XpxGheptm/iIP+bO1nX7lzFOljVlqY6ck=";
  };

  npmDepsHash = "sha256-ZXRAchnjfVXLyIdOwmM+EqLPAEI3pGD595MBlPH7Dko=";
  npmFlags = [ "--ignore-scripts" ];
  nativeBuildInputs = [ typescript_5 ];

  buildPhase = ''
    runHook preBuild
    rm -rf dist
    ${lib.getExe typescript_5} -p tsconfig.json
    runHook postBuild
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ python3 ];
  installCheckPhase = ''
    runHook preInstallCheck
    python ${../../tests/mcp-stdio.py} "$out/bin/elsevier-mcp"
    runHook postInstallCheck
  '';

  meta = {
    description = "MCP server for Elsevier and Scopus";
    homepage = "https://github.com/kemalabuteliyte/elsevier-mcp";
    license = lib.licenses.mit;
    inherit (nodejs_24.meta) platforms;
    mainProgram = "elsevier-mcp";
  };
}
