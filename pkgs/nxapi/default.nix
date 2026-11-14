{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs,
}:
buildNpmPackage rec {
  pname = "nxapi";
  # The upstream remote config disables authentication for obsolete Coral protocols.
  # https://github.com/samuelthomas2774/nxapi/issues/147
  version = "1.6.1-next.257";

  src = fetchurl {
    url = "https://registry.npmjs.org/nxapi/-/nxapi-${version}.tgz";
    hash = "sha256-OGrnT27G8EUNtqxTpM7KJ0HAYr4JOhbX8jv+0Bpu4Oo=";
  };

  npmDepsHash = "sha256-rcJ5jow6Fm17noQHJzD1u9HaTNaCSAXLcZ58nE8ehRY=";

  dontNpmBuild = true;

  forceGitDeps = true;

  npmRebuildFlags = [ "--ignore-scripts" ];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/nxapi $out/bin
    cp -r dist package.json node_modules resources bin $out/lib/node_modules/nxapi/
    find $out/lib/node_modules/nxapi/node_modules -xtype l -delete

    makeWrapper ${nodejs}/bin/node $out/bin/nxapi \
      --add-flags "$out/lib/node_modules/nxapi/bin/nxapi.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Nintendo Switch Online/Parental Controls app API CLI";
    homepage = "https://github.com/samuelthomas2774/nxapi";
    license = licenses.agpl3Only;
    mainProgram = "nxapi";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
