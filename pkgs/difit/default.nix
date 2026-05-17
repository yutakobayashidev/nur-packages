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
  version = "4.0.3";

  src = fetchFromGitHub {
    owner = "yoshiko-pg";
    repo = "difit";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FXxHxujI1hM0LmWm+y9dFiQdtU9GmQmwrbDsegGlSwk=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm_10
    pnpmConfigHook
    git
  ];

  postPatch = ''
    substituteInPlace vite.config.ts \
      --replace-fail "http://localhost:4966" "http://127.0.0.1:4966" \
      --replace-fail "server: {" "server: { host: '127.0.0.1',"
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    hash = "sha256-ze7Z/qV3RYmqrmsdSDLHdbpN9UOZl+68qHxj2Doalio=";
    fetcherVersion = 3;
  };

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  dontStrip = true;

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
