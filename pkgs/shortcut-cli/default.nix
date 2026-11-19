{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  python3,
  openssl,
}:

stdenvNoCC.mkDerivation {
  pname = "shortcut-cli";
  version = "0.1.0-unstable-2026-07-13";

  src = fetchFromGitHub {
    owner = "Wuvomi";
    repo = "shortcut-cli";
    rev = "ef3641eeb7641e126835a2065ce4debccef6224f";
    hash = "sha256-KT04KdPQb5NzAEE32ZvgD1BbNDUNzfby/biGs9GJFQc=";
  };

  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 shortcut_cli.py $out/libexec/shortcut-cli/shortcut_cli.py
    makeWrapper ${python3}/bin/python3 $out/bin/shortcut-cli \
      --add-flags "$out/libexec/shortcut-cli/shortcut_cli.py" \
      ${lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
        --prefix PATH : "${lib.makeBinPath [ openssl ]}" \
        --suffix PATH : /usr/bin
      ''}

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    export SHORTCUT_CLI_LANG=en
    $out/bin/shortcut-cli --help
    $out/bin/shortcut-cli compile examples/hello_alert.json --no-sign -o hello.shortcut
    $out/bin/shortcut-cli info hello.shortcut
    $out/bin/shortcut-cli decompile hello.shortcut -o roundtrip.json
    $out/bin/shortcut-cli compile roundtrip.json --no-sign -o roundtrip.shortcut
    cmp hello.shortcut roundtrip.shortcut

    runHook postInstallCheck
  '';

  meta = {
    description = "Convert between JSON and Apple Shortcuts and fetch iCloud shortcuts";
    homepage = "https://github.com/Wuvomi/shortcut-cli";
    license = lib.licenses.mit;
    mainProgram = "shortcut-cli";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
