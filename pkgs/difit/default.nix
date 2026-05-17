{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  git,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "difit";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "yoshiko-pg";
    repo = "difit";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IV7SuTTLfZkS/pEpXOCMYwPLDNHdQJ71jJjYYjD1c6I=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm_10
    pnpmConfigHook
    git
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-LaKAgA2O+z670LLz+HqOehXblFH1T2hY3s6GUKezR0w=";
    fetcherVersion = 3;
  };

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/difit
    cp -r dist $out/lib/difit/
    cp -r node_modules $out/lib/difit/
    cp package.json $out/lib/difit/
    find $out/lib/difit/node_modules -xtype l -delete

    cat > $out/bin/difit << EOF
    #!/bin/sh
    exec ${nodejs}/bin/node $out/lib/difit/dist/cli/index.js "\$@"
    EOF
    chmod +x $out/bin/difit

    runHook postInstall
  '';

  meta = with lib; {
    description = "A lightweight CLI tool for reviewing Git diffs with a GitHub-style viewer";
    homepage = "https://github.com/yoshiko-pg/difit";
    license = licenses.mit;
    mainProgram = "difit";
  };
})
