{
  lib,
  bash,
  coreutils,
  dbus,
  python3,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  wl-clipboard,
  writableTmpDirAsHomeHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "agent-desktop";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-desktop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0r5bO5oQonq/B/gQYHrjdrQFVfyK3gAZudbaTVe89v0=";
  };

  cargoHash = "sha256-PYZ+PID4Kl3hckTf5RzPXl9JIr+P4lA7Tu2vXXfQ6QM=";

  cargoBuildFlags = [
    "-p"
    "agent-desktop"
    "-p"
    "agent-desktop-linux"
    "--bins"
  ];
  checkType = "debug";
  cargoTestFlags = [
    "-p"
    "agent-desktop-core"
    "-p"
    "agent-desktop-linux"
    "--lib"
  ];

  checkFlags = [
    # Requires a configured display server.
    "--skip=adapter::tests::the_lifecycle_overrides_are_wired_to_the_adapter"
    # Nix coreutils is a multicall binary; /proc reports coreutils, not sleep.
    "--skip=tree::resolve::resolve_errors::tests::a_child_stopped_by_signal_is_named_by_its_listed_name"
  ];

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [
    dbus
    python3
    writableTmpDirAsHomeHook
  ];

  # Upstream unit tests assume a conventional Linux filesystem layout.
  preCheck = ''
    while IFS= read -r -d "" file; do
      substituteInPlace "$file" \
        --replace-quiet /usr/bin/python3 ${python3}/bin/python3 \
        --replace-quiet /bin/bash ${bash}/bin/bash \
        --replace-quiet /bin/true ${coreutils}/bin/true \
        --replace-quiet /bin/false ${coreutils}/bin/false \
        --replace-quiet /bin/sleep ${coreutils}/bin/sleep \
        --replace-quiet /bin/cat ${coreutils}/bin/cat
    done < <(find crates/linux/src -name '*tests.rs' -print0)
    substituteInPlace crates/linux/src/input/clipboard/set_clear_tests.rs \
      --replace-fail 'exec sleep 30' 'exec ${coreutils}/bin/sleep 30'
  '';

  postFixup = ''
    wrapProgram $out/bin/agent-desktop \
      --prefix PATH : ${lib.makeBinPath [ wl-clipboard ]}
  '';

  meta = {
    description = "Operate desktop apps through OS accessibility trees";
    homepage = "https://github.com/vercel-labs/agent-desktop";
    license = lib.licenses.asl20;
    mainProgram = "agent-desktop";
    platforms = lib.platforms.linux;
  };
})
