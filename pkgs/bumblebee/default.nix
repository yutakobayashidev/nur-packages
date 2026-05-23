{
  lib,
  buildGo125Module,
  fetchFromGitHub,
}:
buildGo125Module rec {
  pname = "bumblebee";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "perplexityai";
    repo = "bumblebee";
    rev = "v${version}";
    hash = "sha256-gmB+j1rmnOqHjV2N4hqH2QDolAZ3Za7ztioskZ/FkOQ=";
  };

  vendorHash = null;

  subPackages = [ "cmd/bumblebee" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${version}"
  ];

  meta = with lib; {
    description = "Read-only inventory collector for package, extension, and developer-tool metadata";
    homepage = "https://github.com/perplexityai/bumblebee";
    license = licenses.asl20;
    mainProgram = "bumblebee";
  };
}
