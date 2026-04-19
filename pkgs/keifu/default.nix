{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  perl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "keifu";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "trasta298";
    repo = "keifu";
    rev = "v${version}";
    hash = "sha256-Srw71Rswafu70kKI36dY1PtB4BQhpTYYzqbrWJuvaUM=";
  };

  cargoHash = "sha256-Ga405TV1uDSZbADrV+3aAeLDRfdPFHzdxxTEDu+f+b4=";

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  buildInputs = [ openssl ];

  meta = with lib; {
    description = "A TUI tool for visualizing Git commit graphs";
    homepage = "https://github.com/trasta298/keifu";
    license = licenses.mit;
    mainProgram = "keifu";
  };
}
