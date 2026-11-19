{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  python3,
  typescript,
}:

(buildNpmPackage.override { nodejs = nodejs_24; }) {
  pname = "pubmed-mcp-server";
  version = "2.12.1";

  src = fetchFromGitHub {
    owner = "cyanheads";
    repo = "pubmed-mcp-server";
    rev = "192a25a580921eb5210ce18acfe14d10fe7675ae";
    hash = "sha256-tv2j1imlhkRZxTGQ/zSZg+PHOTWd5cxxvBx4Ux9Gpi8=";
  };

  npmDepsHash = "sha256-UcpEV5t1vYYaBnb1vSbuS+iyYy2wqEjMHzzob6cYdbE=";
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
    python ${../../tests/mcp-stdio.py} "$out/bin/pubmed-mcp-server"
    runHook postInstallCheck
  '';

  meta = {
    description = "MCP server for PubMed biomedical literature";
    homepage = "https://github.com/cyanheads/pubmed-mcp-server";
    license = lib.licenses.asl20;
    inherit (nodejs_24.meta) platforms;
    mainProgram = "pubmed-mcp-server";
  };
}
