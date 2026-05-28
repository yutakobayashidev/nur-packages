{
  lib,
  buildNpmPackage,
  fetchurl,
  git,
  nodejs,
  makeWrapper,
}:
buildNpmPackage rec {
  pname = "nxapi";
  version = "1.6.1-next.254";

  src = fetchurl {
    url = "https://registry.npmjs.org/nxapi/-/nxapi-${version}.tgz";
    hash = "sha256-BGEGrNhJ2qWy2AXRDH1qi2di2bUWhAhKAvsg+tQn/GM=";
  };

  npmDepsHash = "sha256-b/A8xls+GPtz6JvtYjSGvQrrg8h4mz/R3FUonp80658=";

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
