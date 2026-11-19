{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
}:

buildNpmPackage {
  pname = "kohaku-cli";
  version = "0.1.0-unstable-2026-11-01";

  src = fetchFromGitHub {
    owner = "kassandraoftroy";
    repo = "kohaku-cli";
    rev = "0ef5c441a566b3ccfbbbf59b5189591d7314002f";
    hash = "sha256-WIbRazScBuqQP/pubzlFL5PP4bRbJcPXdijMvoJTnrU=";
  };

  # Upstream locks native build dependencies for darwin-arm64 only.
  patches = [ ./package-lock.patch ];

  nodejs = nodejs_22;
  makeCacheWritable = true;
  npmDepsHash = "sha256-5ou0WDGj6IyPwt3mvhHfg8H73xRQ0v9MXMTRYmhSot4=";

  # npm pack follows upstream's .gitignore, which excludes the built CLI.
  postInstall = ''
    cp -r dist $out/lib/node_modules/kohaku-cli/
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/kohaku --version
    $out/bin/kohaku --help > /dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "Command-line Ethereum wallet with privacy protocol support";
    homepage = "https://github.com/kassandraoftroy/kohaku-cli";
    license = lib.licenses.mit;
    mainProgram = "kohaku";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}
