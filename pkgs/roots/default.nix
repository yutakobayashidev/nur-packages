{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:
buildGoModule rec {
  pname = "roots";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "k1LoW";
    repo = "roots";
    rev = "v${version}";
    hash = "sha256-ACMRfWY/lhc3C/KVhuUyS1rgkSHGWPxZrmYt+pXupJI=";
  };

  vendorHash = "sha256-uxcT5VzlTCxxnx09p13mot0wVbbas/otoHdg7QSDt4E=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/k1LoW/roots/version.Version=${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    $out/bin/roots completion bash > roots.bash
    $out/bin/roots completion fish > roots.fish
    $out/bin/roots completion zsh > _roots

    installShellCompletion --cmd roots \
      --bash roots.bash \
      --fish roots.fish \
      --zsh _roots
  '';

  meta = with lib; {
    description = "CLI for finding root directories in monorepo";
    homepage = "https://github.com/k1LoW/roots";
    license = licenses.mit;
    mainProgram = "roots";
  };
}
