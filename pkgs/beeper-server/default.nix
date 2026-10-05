{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  stdenv,
}:

stdenvNoCC.mkDerivation {
  pname = "beeper-server";
  version = "4.3.149";

  src = fetchurl {
    url = "https://beeper-desktop.download.beeper.com/builds/beeper-server-nightly-4.3.149-linux-x64.tar.gz";
    hash = "sha512-F2nWMVucMn6lOiBlmnACu1MUxCgbvdZvhAl1cZwaiYY6tl5eUe6+r2RA8jsnJccCpe3wsBXHk3vcLFZXaMIrVA==";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 beeper-server "$out/bin/beeper-server"
    runHook postInstall
  '';

  meta = {
    description = "Headless Beeper Client API server (nightly)";
    homepage = "https://github.com/beeper/cli";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "beeper-server";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
