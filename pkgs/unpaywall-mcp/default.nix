{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  python3,
  typescript_5,
}:

(buildNpmPackage.override { nodejs = nodejs_24; }) {
  pname = "unpaywall-mcp";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "ElliotPadfield";
    repo = "unpaywall-mcp";
    rev = "39baf601d933b1443d3919afbb97eee229d775f8";
    hash = "sha256-9ZyHNatqF+07EWHLncBmZwwOKa9kjjjVAFjwzQTCsj8=";
  };

  npmDepsHash = "sha256-NoVDuabOX4vgJbIA/R5cPYgw8O4n4MWmq4UACSRSKrU=";
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
    python ${../../tests/mcp-stdio.py} "$out/bin/unpaywall-mcp"
    runHook postInstallCheck
  '';

  meta = {
    description = "MCP server for Unpaywall open-access papers";
    homepage = "https://github.com/ElliotPadfield/unpaywall-mcp";
    license = lib.licenses.mit;
    inherit (nodejs_24.meta) platforms;
    mainProgram = "unpaywall-mcp";
  };
}
