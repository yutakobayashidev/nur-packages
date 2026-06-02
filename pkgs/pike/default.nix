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

  vendorHash = "sha256-JqT2IHdQzQ56w6kFyuMMhsWsbICrmRSWfym0TdJUvrQ=";

  doCheck = false;

  postPatch = ''
    sed -i 's/go 1\.26\.[0-9]*/go 1.26.1/' go.mod
  '';

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
