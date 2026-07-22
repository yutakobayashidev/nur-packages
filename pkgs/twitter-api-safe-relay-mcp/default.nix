{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "twitter-api-safe-relay-mcp";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "nakasyou";
    repo = "twitter_api_safe_relay_mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NJkdcuV8u4+lPwDCgoavCs94hWNNmemvuCPMKyoAgLc=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-SVoEtTXZ2oc97oNJOJy+hntV5/9rTHh4ZhO0aMJkGIY=";

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    npm test

    runHook postCheck
  '';

  meta = {
    description = "Safe MCP server for twitter_api_safe_relay";
    homepage = "https://github.com/nakasyou/twitter_api_safe_relay_mcp";
    license = lib.licenses.mit;
    mainProgram = "twitter_api_safe_relay_mcp";
    platforms = lib.platforms.unix;
  };
})
