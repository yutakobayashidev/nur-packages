{
  stdenvNoCC,
  fetchurl,
  unzip,
  lib,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tim012432-calendarheatmap-panel";
  version = "1.2.1";

  src = fetchurl {
    name = "${finalAttrs.pname}-${finalAttrs.version}.zip";
    url = "https://grafana.com/api/plugins/${finalAttrs.pname}/versions/${finalAttrs.version}/download";
    hash = "sha256-Yjmpws6vKMp5Yqy+8A2PZHsI7CiJN5gprkGE+BqTQco=";
  };

  nativeBuildInputs = [ unzip ];
  dontBuild = true;
  # Preserve the Grafana catalog's community signature and bundled assets.
  dontFixup = true;
  installPhase = ''
    runHook preInstall
    cp -R . "$out"
    runHook postInstall
  '';

  meta = {
    description = "GitHub-style daily activity calendar for Grafana";
    homepage = "https://grafana.com/grafana/plugins/${finalAttrs.pname}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
