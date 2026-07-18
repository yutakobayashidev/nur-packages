{
  lib,
  stdenvNoCC,
  fetchurl,
  bun,
  makeWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "course-cli";
  version = "0.0.5";

  src = fetchurl {
    url = "https://git.yutakobayashi.com/api/packages/yuta/npm/%40yuta%2Fcourse-cli/-/${finalAttrs.version}/course-cli-${finalAttrs.version}.tgz";
    hash = "sha256-6dqA/uZs8uAKtC8gTDemoRrPMDXlRMkiXmb9xo2I3rg=";
  };

  sourceRoot = "package";
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm644 dist/course-cli.js $out/libexec/${finalAttrs.pname}/course-cli.js
    makeWrapper ${bun}/bin/bun $out/bin/course-cli \
      --add-flags $out/libexec/${finalAttrs.pname}/course-cli.js

    runHook postInstall
  '';

  meta = {
    description = "Course API CLI";
    homepage = "https://git.yutakobayashi.com/yuta/-/packages/npm/%40yuta%2Fcourse-cli/${finalAttrs.version}";
    mainProgram = "course-cli";
    platforms = lib.platforms.unix;
  };
})
