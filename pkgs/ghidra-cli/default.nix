{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  ghidra,
  jdk21,
}:

rustPlatform.buildRustPackage rec {
  pname = "ghidra-cli";
  version = "0.10.3-unstable-2026-11-04";

  src = fetchFromGitHub {
    owner = "toratako";
    repo = "ghidra-cli";
    rev = "11bc1346aacbc339fea1e9d0bbe3525d99e96676";
    hash = "sha256-d+4p2o95WYlPLp3XoajF2flw0eGpRDrdETbaVmvMvWo=";
  };
  cargoHash = "sha256-KAbVZmtNit3Q7EvMQE2tD3HqnuZuyVFj/P0oTK/eKPw=";
  nativeBuildInputs = [ makeWrapper ];

  # Runtime integration is checked separately with a writable project and JVM.
  cargoTestFlags = [
    "--lib"
    "--bin"
    "ghidra-cli"
  ];

  preCheck = ''
    export XDG_CONFIG_HOME="$TMPDIR/test-config"
    export XDG_DATA_HOME="$TMPDIR/test-data"
    export XDG_CACHE_HOME="$TMPDIR/test-cache"
    mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME"
  '';

  postFixup = ''
    wrapProgram $out/bin/ghidra-cli \
      --set-default GHIDRA_INSTALL_DIR "${ghidra}/lib/ghidra" \
      --set-default GHIDRA_CLI_JAVA_HOME "${jdk21}"
  '';

  passthru = {
    inherit ghidra;
    skillSource = "${src}/docs/skills";
  };

  meta = {
    description = "Headless Ghidra CLI for agent-driven reverse engineering";
    homepage = "https://github.com/toratako/ghidra-cli";
    license = lib.licenses.gpl3Only;
    mainProgram = "ghidra-cli";
    platforms = ghidra.meta.platforms;
  };
}
