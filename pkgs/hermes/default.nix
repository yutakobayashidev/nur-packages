{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hermes";
  version = "0.0.1";

  src = fetchurl {
    url = "https://hermes-assets.nousresearch.com/Hermes-Setup.dmg";
    hash = "sha256-ObPwe+h4ROrPzY6GZcwW9uc+RxPz72MZtsTelK6uw8c=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -pR "Hermes Setup.app" "$out/Applications/"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Desktop app for Hermes AI assistant by Nous Research";
    homepage = "https://nousresearch.com";
    license = licenses.unfree;
    platforms = platforms.darwin;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
  };
})
