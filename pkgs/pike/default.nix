{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "pike";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "JamesWoolfenden";
    repo = "pike";
    rev = "v${version}";
    hash = "sha256-zGaN0ee/1oOXxxvUirF9fhtHAin00Wjt8LRNcZjbuU8=";
  };

  vendorHash = "sha256-R0u02G6qq1Fx9eNq+PECFeNBDpN8SWY5vGOsqhwGteE=";

  proxyVendor = true;

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Tool for determining the minimum IAM permissions required to run OpenTofu/Terraform infrastructure code";
    homepage = "https://github.com/JamesWoolfenden/pike";
    license = licenses.asl20;
    mainProgram = "pike";
  };
}
