{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  cacert,
  makeWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr-symphony";
  version = "0-unstable-2026-11-19";

  src = fetchFromGitHub {
    owner = "yutakobayashidev";
    repo = "herdr-symphony";
    rev = "b74d05f6096eb10ef91a28eb017f10a3737e4a57";
    hash = "sha256-V8trV3abg2NAfHWi09VceK1G22kuhkIdjSkJjbFtG1g=";
  };

  nodeModules = stdenvNoCC.mkDerivation {
    pname = "herdr-symphony-node-modules";
    inherit (finalAttrs) version src;
    nativeBuildInputs = [ bun cacert ];
    buildPhase = ''
      export HOME="$TMPDIR"
      bun install --frozen-lockfile --production --ignore-scripts --no-progress
    '';
    installPhase = ''
      cp -r node_modules "$out"
    '';
    dontFixup = true;
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-dyVrjJIUEh/98q0Vf+Fo/QrAtR60/kW/6e+R0tQKnZ0=";
  };

  nativeBuildInputs = [ bun makeWrapper ];
  buildPhase = ''
    runHook preBuild
    cp -r ${finalAttrs.nodeModules} node_modules
    cp bin/herdr-symphony bin/herdr-symphony.ts
    bun build --target=bun ./bin/herdr-symphony.ts --outdir=dist
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/libexec/herdr-symphony"
    cp -r dist/. "$out/libexec/herdr-symphony/"
    makeWrapper ${bun}/bin/bun "$out/bin/herdr-symphony" \
      --add-flags "$out/libexec/herdr-symphony/herdr-symphony.js"
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    export HOME="$TMPDIR"
    export XDG_CACHE_HOME="$TMPDIR/cache"
    "$out/bin/herdr-symphony" --help >help.txt 2>&1 || { cat help.txt; exit 1; }
    grep -q "herdr-symphony" help.txt
  '';

  meta = {
    description = "GitHub Project issue orchestrator for Herdr agents";
    homepage = "https://github.com/yutakobayashidev/herdr-symphony";
    license = lib.licenses.mit;
    mainProgram = "herdr-symphony";
    platforms = lib.platforms.unix;
  };
})
