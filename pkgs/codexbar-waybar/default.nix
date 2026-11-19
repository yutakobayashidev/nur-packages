{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  coreutils,
  curl,
  gnused,
  jq,
  libnotify,
  shellcheck,
  util-linux,
}:

stdenvNoCC.mkDerivation rec {
  pname = "codexbar";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "mryll";
    repo = "codexbar";
    tag = "v${version}";
    hash = "sha256-wZhSYrDoLCQQvxXz9NIsp8n1+YIXlGZNGfBwvZEIAZk=";
  };

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [
    coreutils
    curl
    gnused
    jq
    shellcheck
  ];

  dontBuild = true;
  doCheck = true;
  checkPhase = ''
    runHook preCheck

    bash -n codexbar
    warnings="$(shellcheck -S style codexbar | grep -cE 'SC[0-9]+ \(' || true)"
    test "$warnings" -le 4

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 codexbar $out/bin/codexbar
    wrapProgram $out/bin/codexbar \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          curl
          gnused
          jq
          libnotify
          util-linux
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "Waybar widget for OpenAI Codex subscription usage";
    homepage = "https://github.com/mryll/codexbar";
    license = lib.licenses.mit;
    mainProgram = "codexbar";
    platforms = lib.platforms.linux;
  };
}
