{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "tfmv";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "suzuki-shunsuke";
    repo = "tfmv";
    rev = "v${version}";
    hash = "sha256-zX2s49NU2m8BITz0uJxAgQpJa4Fl7Zt71f3Q8hU32K4=";
  };

  vendorHash = "sha256-cSUjE2IZjPuFzXaQ0BlGU8CbwgK0n/x1nsPt7Pokg/w=";

  subPackages = [ "cmd/tfmv" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = with lib; {
    description = "CLI to rename Terraform resources, data sources, and modules and generate moved blocks";
    homepage = "https://github.com/suzuki-shunsuke/tfmv";
    license = licenses.mit;
    mainProgram = "tfmv";
    platforms = platforms.unix;
  };
}
