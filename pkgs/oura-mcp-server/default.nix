{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  python3,
  typescript_5,
}:

(buildNpmPackage.override { nodejs = nodejs_24; }) {
  pname = "oura-mcp-server";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "trenerok";
    repo = "oura-mcp-server";
    rev = "d4e1304c5c9cea7573bde001b3c047410e3a2987";
    hash = "sha256-kpYd57NWAU7j9zvB2nJM42tE7mi1QxKmnXXxHfCF1Z8=";
  };

  npmDepsHash = "sha256-Wn39gPzPM2o1kh6ffIvqpTmhwMIMhOHluBshc6Nyt7k=";
  npmFlags = [ "--ignore-scripts" ];
  nativeBuildInputs = [ typescript_5 ];

  postPatch = ''
    substituteInPlace package.json --replace-fail '"main": "dist/index.js",' '"main": "dist/index.js", "bin": { "oura-mcp-server": "dist/index.js" },'
  '';

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
    python ${../../tests/mcp-stdio.py} "$out/bin/oura-mcp-server"
    runHook postInstallCheck
  '';

  meta = {
    description = "MCP server for Oura Ring health data";
    homepage = "https://github.com/trenerok/oura-mcp-server";
    license = lib.licenses.mit;
    inherit (nodejs_24.meta) platforms;
    mainProgram = "oura-mcp-server";
  };
}
