{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpm_11,
  pnpmConfigHook,
  makeWrapper,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "webforai";
  version = "5.0.2";

  src = fetchFromGitHub {
    owner = "inaridiy";
    repo = "webforai";
    tag = "webforai@${finalAttrs.version}";
    hash = "sha256-SgQUqlFw+XGl4FlfsawpkapXeyHzG7+wbcFRvg1JcuM=";
  };

  pnpmWorkspaces = [ "webforai-cli..." ];
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;
    pnpm = pnpm_11;
    fetcherVersion = 4;
    hash = "sha256-m/yBLvpWfXnyGuSKjXJYiffKELFnMmgnXwHhTsXzC4E=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm_11
    (pnpmConfigHook.override { pnpm = pnpm_11; })
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild
    pnpm --filter 'webforai-cli...' --recursive run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    pnpm config set --location=project inject-workspace-packages true
    pnpm --filter webforai-cli deploy --prod --offline "$out/lib/webforai"
    makeWrapper ${lib.getExe nodejs} "$out/bin/webforai" \
      --add-flags "$out/lib/webforai/dist/bin.js"
    install -Dm644 LICENSE "$out/share/doc/webforai/LICENSE"
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  installCheckPhase = ''
    runHook preInstallCheck
    printf '<html><body><h1>Package check</h1><p>Original <strong>Markdown</strong> text.</p></body></html>' > page.html
    "$out/bin/webforai" page.html --extractor none > page.md
    grep -F '# Package check' page.md
    grep -F '**Markdown**' page.md
    runHook postInstallCheck
  '';

  meta = {
    description = "Convert web pages and local HTML to clean Markdown";
    homepage = "https://github.com/inaridiy/webforai";
    license = lib.licenses.asl20;
    inherit (nodejs.meta) platforms;
    mainProgram = "webforai";
  };
})
