{
  lib,
  stdenvNoCC,
  python3,
  tzdata,
  cacert,
  makeWrapper,
}:

stdenvNoCC.mkDerivation {
  pname = "tibo-reset-monitor";
  version = "0.1.0";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [ ./monitor.py ./test_monitor.py ];
  };
  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ python3 ];
  dontBuild = true;
  doCheck = true;
  checkPhase = ''
    runHook preCheck
    export PYTHONTZPATH=${tzdata}/share/zoneinfo
    python -m unittest -v test_monitor.py
    runHook postCheck
  '';
  installPhase = ''
    runHook preInstall
    install -Dm644 monitor.py $out/lib/tibo-reset-monitor/monitor.py
    makeWrapper ${python3}/bin/python3 $out/bin/tibo-reset-monitor \
      --add-flags $out/lib/tibo-reset-monitor/monitor.py \
      --set PYTHONTZPATH ${tzdata}/share/zoneinfo \
      --set-default SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt
    runHook postInstall
  '';
  meta = {
    description = "Notify Discord of newly tracked Codex resets and reset credits";
    homepage = "https://codex-resets.com";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "tibo-reset-monitor";
  };
}
