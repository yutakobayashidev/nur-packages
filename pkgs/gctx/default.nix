{
  lib,
  stdenvNoCC,
  makeWrapper,
  babashka,
  fzf,
  google-cloud-sdk,
}:
stdenvNoCC.mkDerivation {
  pname = "gctx";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 gctx.clj "$out/bin/gctx"
    wrapProgram "$out/bin/gctx" \
      --prefix PATH : "${
        lib.makeBinPath [
          babashka
          fzf
          google-cloud-sdk
        ]
      }"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Google Cloud named configuration switcher";
    mainProgram = "gctx";
    platforms = platforms.unix;
  };
}
