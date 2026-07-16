{
  lib,
  stdenvNoCC,
  fetchurl,
  bun,
  makeWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "course-cli";
  version = "0.0.2";

  src = fetchurl {
    url = "https://git.yutakobayashi.com/api/packages/yuta/npm/%40yuta%2Fcourse-cli/-/${finalAttrs.version}/course-cli-${finalAttrs.version}.tgz";
    hash = "sha256-cyLA6Z/hBIlVJlhNy5iIvIWpwDmU+TVE6pXrwqWHblw=";
  };

  sourceRoot = "package";
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm644 dist/nnn.js $out/libexec/${finalAttrs.pname}/nnn.js
    makeWrapper ${bun}/bin/bun $out/bin/nnn \
      --add-flags $out/libexec/${finalAttrs.pname}/nnn.js

    runHook postInstall
  '';

  meta = {
    description = "Course API CLI";
    homepage = "https://git.yutakobayashi.com/yuta/-/packages/npm/%40yuta%2Fcourse-cli/${finalAttrs.version}";
    mainProgram = "nnn";
    platforms = lib.platforms.unix;
  };
})
