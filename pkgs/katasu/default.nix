{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
  makeWrapper,
}:

buildNpmPackage (finalAttrs: {
  pname = "katasu";
  version = "0.0.3-beta.20260709162625";

  src = fetchurl {
    url = "https://registry.npmjs.org/katasu/-/katasu-${finalAttrs.version}.tgz";
    hash = "sha256-wwTcpLZ4O821RHPoePbMykMcWM1wuZ7WOaTCHgjygqE=";
  };

  sourceRoot = "package";
  postPatch = ''
    cp ${./package.json} package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-gdaGx0plqry2tA4qBn9U7Swxio8zGx05vg4zJ+YpxrE=";
  nodejs = nodejs_22;
  dontNpmBuild = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}
    cp -r dist package.json node_modules $out/lib/${finalAttrs.pname}/
    find $out/lib/${finalAttrs.pname}/node_modules -xtype l -delete
    makeWrapper ${nodejs_22}/bin/node $out/bin/katasu \
      --add-flags $out/lib/${finalAttrs.pname}/dist/cli.js

    runHook postInstall
  '';

  meta = {
    description = "Command-line tools for reading and updating Katasu tasks";
    homepage = "https://www.katasu.app";
    mainProgram = "katasu";
    platforms = lib.platforms.unix;
  };
})
