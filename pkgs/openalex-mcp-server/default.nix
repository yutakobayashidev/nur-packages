{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  python3,
  typescript,
}:

(buildNpmPackage.override { nodejs = nodejs_24; }) {
  pname = "openalex-mcp-server";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "cyanheads";
    repo = "openalex-mcp-server";
    rev = "a61de9a640530e88f059b8a6cd22dc994dfd7425";
    hash = "sha256-9l5b7E0keb+2umcfbdSWaE6ROYyFtQX5fydibBQVfY4=";
  };

  npmDepsHash = "sha256-BCA9T15HHX89gdhWHEfCAjMJdDK6Dfr4zWxSGKs7TTs=";
  npmFlags = [ "--ignore-scripts" ];
  # Optional framework peers include test tooling and prebuilt native addons.
  # The server's supported providers are declared as direct dependencies.
  npmPruneFlags = [ "--omit=optional" ];
  nativeBuildInputs = [ typescript ];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  buildPhase = ''
    runHook preBuild
    rm -rf dist
    ${lib.getExe typescript} -p tsconfig.build.json
    node_modules/.bin/tsc-alias -p tsconfig.build.json
    runHook postBuild
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ python3 ];
  installCheckPhase = ''
    runHook preInstallCheck
    python ${../../tests/mcp-stdio.py} "$out/bin/openalex-mcp-server"
    runHook postInstallCheck
  '';

  meta = {
    description = "MCP server for OpenAlex scholarly data";
    homepage = "https://github.com/cyanheads/openalex-mcp-server";
    license = lib.licenses.asl20;
    inherit (nodejs_24.meta) platforms;
    mainProgram = "openalex-mcp-server";
  };
}
