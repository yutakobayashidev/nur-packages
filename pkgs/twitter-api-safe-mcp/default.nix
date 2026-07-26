{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeWrapper,
  nodejs,
  pnpm_11,
  pnpmConfigHook,
}:

let
  enableInjectedWorkspacePackages = ''
    substituteInPlace pnpm-lock.yaml \
      --replace-fail \
        "settings:" \
        $'settings:\n  injectWorkspacePackages: true'
    printf '\ninjectWorkspacePackages: true\n' >> pnpm-workspace.yaml
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "twitter-api-safe-mcp";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "fa0311";
    repo = "twitter_api_safe_relay";
    rev = "0026d9d6a879a5ac263db8ba3563fd09e4f6aa10";
    hash = "sha256-IGWEPNf5C1sU3T80zpsYfZe/tLKN8l5X+Z7QwWSmCfg=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    hash = "sha256-xrb+bHUCt2Pm+PnPHQ55BWb+vq8jSShH+yNwQDqrS7M=";
    fetcherVersion = 4;
    postPatch = enableInjectedWorkspacePackages;
  };

  postPatch = enableInjectedWorkspacePackages;

  nativeBuildInputs = [
    nodejs
    pnpm_11
    pnpmConfigHook
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild

    pnpm --filter twitter-api-safe-relay-dashboard build
    pnpm --filter twitter-api-safe-mcp build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm --filter twitter-api-safe-mcp --prod deploy --offline $out/lib/${finalAttrs.pname}
    makeWrapper ${nodejs}/bin/node $out/bin/twitter-api-safe-mcp \
      --add-flags $out/lib/${finalAttrs.pname}/dist/server.js

    runHook postInstall
  '';

  meta = {
    description = "MCP server for safe Twitter/X web API requests through Playwright profiles";
    homepage = "https://github.com/fa0311/twitter_api_safe_relay/tree/main/packages/mcp";
    license = lib.licenses.mit;
    mainProgram = "twitter-api-safe-mcp";
    platforms = lib.platforms.unix;
  };
})
