{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  python3,
  typescript_5,
}:

(buildNpmPackage.override { nodejs = nodejs_24; }) {
  pname = "semanticscholar-mcp";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "xbghc";
    repo = "semanticscholar-mcp";
    rev = "4070c5b0cefb2d02142dc040486e5d9c480ccf32";
    hash = "sha256-FLTMOF5EeXptfWbATY2pVn79cDqHmlwZvyBkRPC54wk=";
  };

  npmDepsHash = "sha256-6TF8k2GYSOxX3cEoESN9S1L+sDg2Gb3PkeBVJz7sodo=";
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
    python ${../../tests/mcp-stdio.py} "$out/bin/semanticscholar-mcp"
    runHook postInstallCheck
  '';

  meta = {
    description = "MCP server for Semantic Scholar";
    homepage = "https://github.com/xbghc/semanticscholar-mcp";
    license = lib.licenses.mit;
    inherit (nodejs_24.meta) platforms;
    mainProgram = "semanticscholar-mcp";
  };
}
