{
  lib,
  rustPlatform,
  fetchFromGitHub,
  gh,
  git,
  makeWrapper,
}:
rustPlatform.buildRustPackage rec {
  pname = "rinkaku";
  version = "0.6.19";

  src = fetchFromGitHub {
    owner = "hiro-o918";
    repo = "rinkaku";
    rev = "v${version}";
    hash = "sha256-BDEZXugnRACChflHivNPJ3HVVhUplUA+dxAHxCDrCsc=";
  };

  cargoHash = "sha256-li4kNMVY1tQPts8+6ja691U0Ge8V29f/DbF0MPaVOMI=";

  cargoBuildFlags = [ "-p rinkaku" ];
  cargoTestFlags = [ "--workspace" ];
  checkType = "debug";

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ git ];

  postInstall = ''
    wrapProgram $out/bin/rinkaku \
      --set-default RINKAKU_UPDATE_CHECK 0 \
      --prefix PATH : ${lib.makeBinPath [
        gh
        git
      ]}
  '';

  meta = {
    description = "See the shape of a pull request before reading it";
    homepage = "https://github.com/hiro-o918/rinkaku";
    license = lib.licenses.mit;
    mainProgram = "rinkaku";
    platforms = lib.platforms.unix;
  };
}
