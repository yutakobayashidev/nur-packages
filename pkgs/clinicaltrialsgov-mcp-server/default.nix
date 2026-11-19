{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  python3,
  typescript,
}:

(buildNpmPackage.override { nodejs = nodejs_24; }) {
  pname = "clinicaltrialsgov-mcp-server";
  version = "2.11.2";

  src = fetchFromGitHub {
    owner = "cyanheads";
    repo = "clinicaltrialsgov-mcp-server";
    rev = "043fd4f2c25cdbdb18a5c99b4edba6f822da2f5f";
    hash = "sha256-0whiI3pvWG6+1uwK/g0Es6oX9glT4YP/19Hd+NpOYZc=";
  };

  npmDepsHash = "sha256-wDgd1TcoTUnrGHskLrhNf8I4wXFqo2PQlg8g8HkcV6o=";
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
    python ${../../tests/mcp-stdio.py} "$out/bin/clinicaltrialsgov-mcp-server"
    runHook postInstallCheck
  '';

  meta = {
    description = "MCP server for ClinicalTrials.gov";
    homepage = "https://github.com/cyanheads/clinicaltrialsgov-mcp-server";
    license = lib.licenses.asl20;
    inherit (nodejs_24.meta) platforms;
    mainProgram = "clinicaltrialsgov-mcp-server";
  };
}
