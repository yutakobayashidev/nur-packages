{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpm_11,
  pnpmConfigHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "opensrc";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "opensrc";
    rev = "1fe9dbcafb8ee54010cea75e651190f903ab4e69";
    hash = "sha256-oHI1NX20IpvwyExN0bBv79FoUihkHV5+N4DlWlPWNMQ=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-A7maOctmaEfhQnCxloYE/SwmfyLQRD+8l3gS9GJbzqI=";
    fetcherVersion = 4;
    pnpm = pnpm_11;
  };

  nativeBuildInputs = [
    nodejs
    (pnpmConfigHook.override { pnpm = pnpm_11; })
    pnpm_11
  ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/opensrc
    cp -r dist $out/lib/opensrc/
    cp -r node_modules $out/lib/opensrc/
    cp package.json $out/lib/opensrc/

    cat > $out/bin/opensrc << EOF
    #!/bin/sh
    exec ${nodejs}/bin/node $out/lib/opensrc/dist/index.js "\$@"
    EOF
    chmod +x $out/bin/opensrc

    runHook postInstall
  '';

  meta = with lib; {
    description = "Fetch and manage source code from package registries for AI coding agents";
    homepage = "https://github.com/vercel-labs/opensrc";
    license = licenses.mit;
    mainProgram = "opensrc";
  };
})
