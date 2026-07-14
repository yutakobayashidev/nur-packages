{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  makeWrapper,
  chromium,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nlobby-cli";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "minagishl";
    repo = "nlobby-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OFogs/BcFg+e/n6O/wCOGX4fJv/XT+heVQ+EJdeuTzI=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    hash = "sha256-1VJYs24hNkjH4BJSUMecbCNSwBgzx8Fb+ieNVVsS68Q=";
    fetcherVersion = 3;
  };

  nativeBuildInputs = [
    nodejs
    pnpm_10
    pnpmConfigHook
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm prune --prod --ignore-scripts
    mkdir -p $out/lib/${finalAttrs.pname}
    cp -r dist node_modules package.json $out/lib/${finalAttrs.pname}/
    find $out/lib/${finalAttrs.pname}/node_modules -xtype l -delete
    makeWrapper ${nodejs}/bin/node $out/bin/nlobby \
      --add-flags $out/lib/${finalAttrs.pname}/dist/index.js \
      ${lib.optionalString stdenv.hostPlatform.isLinux "--set PUPPETEER_EXECUTABLE_PATH ${lib.getExe chromium}"}
    ln -s nlobby $out/bin/nlobby-mcp

    runHook postInstall
  '';

  meta = {
    description = "CLI and MCP server for N Lobby school portal";
    homepage = "https://github.com/minagishl/nlobby-cli";
    license = lib.licenses.mit;
    mainProgram = "nlobby";
    platforms = lib.platforms.unix;
  };
})
