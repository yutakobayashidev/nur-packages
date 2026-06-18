{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  git,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  agent-browser,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "before-and-after";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "before-and-after";
    rev = "v${finalAttrs.version}";
    hash = "sha256-DfkpfEpqFTnYWat0+2a/XfrEgfD2cNzl/KOKuf7W6tQ=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm_10
    pnpmConfigHook
    git
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    hash = "sha256-xbyQ22j2eMoYKSDmSWg3aUDvFskFdQa5cIGvPRtwi6k=";
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

    mkdir -p $out/bin $out/lib/before-and-after
    cp -r dist $out/lib/before-and-after/
    cp -r node_modules $out/lib/before-and-after/
    cp package.json $out/lib/before-and-after/
    find $out/lib/before-and-after/node_modules -xtype l -delete
    find $out/lib/before-and-after/node_modules -name 'agent-browser-*-*' -type f ! -name '*.js' -exec chmod +x {} \;

    cat > $out/bin/before-and-after << EOF
    #!/bin/sh
    export PATH="${lib.getBin agent-browser}/bin:${nodejs}/bin:$out/lib/before-and-after/node_modules/.bin:\$PATH"
    exec ${nodejs}/bin/node $out/lib/before-and-after/dist/bin/cli.js "\$@"
    EOF
    chmod +x $out/bin/before-and-after

    runHook postInstall
  '';

  meta = with lib; {
    description = "Simple before/after screenshot tool for capturing and comparing web pages";
    homepage = "https://github.com/vercel-labs/before-and-after";
    license = licenses.unfree;
    mainProgram = "before-and-after";
  };
})
