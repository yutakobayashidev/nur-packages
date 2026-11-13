{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  python3,
  typescript,
}:

(buildNpmPackage.override { nodejs = nodejs_24; }) {
  pname = "crossref-mcp-server";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "cyanheads";
    repo = "crossref-mcp-server";
    rev = "a438455a9d7d3ae0cade51d218c8a87ea3293880";
    hash = "sha256-ubkkSGLUs96T2ejBxPg+Rdu9SDNb2PBWltfbsyrOGLI=";
  };

  npmDepsHash = "sha256-/ipGWYzym4/ylzyHAd3AlMXpgV7KeH4M5uwgTl0fskw=";
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
    python ${../../tests/mcp-stdio.py} "$out/bin/crossref-mcp-server"
    runHook postInstallCheck
  '';

  meta = {
    description = "MCP server for Crossref scholarly metadata";
    homepage = "https://github.com/cyanheads/crossref-mcp-server";
    license = lib.licenses.asl20;
    inherit (nodejs_24.meta) platforms;
    mainProgram = "crossref-mcp-server";
  };
}
