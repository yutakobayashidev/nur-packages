{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "nature-remo-cli";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "chroju";
    repo = "nature-remo-cli";
    rev = "v${version}";
    hash = "sha256-BKu06DudLyfJJKUL1o+VcH2MBoOf4bwliEjBSfa9Ih0=";
  };

  vendorHash = "sha256-4xmvVr//yy74VZ5IvHfL2WkZL6+CPPDD5/mfOuSInV0=";

  env.CGO_ENABLED = 0;

  postPatch = ''
    substituteInPlace main.go \
      --replace-fail 'version = "0.3.0"' 'version = "${version}"'
  '';

  postInstall = ''
    mv $out/bin/nature-remo-cli $out/bin/remo
  '';

  meta = {
    description = "Unofficial command line interface for Nature Remo";
    homepage = "https://github.com/chroju/nature-remo-cli";
    license = lib.licenses.mit;
    mainProgram = "remo";
  };
}
