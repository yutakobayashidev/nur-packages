# Adapted from lorenzorapetti/nix at a4ce94d8b64daa2ddc5e02d3fff690b1d17ca693.
# See ../herdr-app/LICENSE.packaging for the packaging license.
# Refresh Ghostty, Zig dependency and Cargo hashes together when updating.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  zig_0_16,
  lld,
}:

let
  version = "0.1.14";
  ghosttyRev = "1e5cdb865807abc990181efb8ebfa9122955cce2";

  ghostty = fetchFromGitHub {
    owner = "ghostty-org";
    repo = "ghostty";
    rev = ghosttyRev;
    hash = "sha256-WaOzgEyVokKpzYpd+TA12i8qO/4TyQPhH+RWDfvjKe0=";
  };

  zigDeps = zig_0_16.fetchDeps {
    pname = "herdr-core-ghostty";
    version = builtins.substring 0 7 ghosttyRev;
    src = ghostty;
    fetchAll = true;
    hash = "sha256-G9xbZ/pyQTDIfzG0h++i70a45zpwyYpZMBZfAnoOQw0=";
  };
in
rustPlatform.buildRustPackage {
  pname = "herdr-core";
  inherit version;

  # vendor/ghostty is a submodule, filled in postUnpack.
  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr-core";
    rev = "v${version}";
    hash = "sha256-9HYUOGzgFhhqxggt6CrX2db+hIOCBpBs2b9wlOhPKN4=";
  };

  cargoHash = "sha256-A3sxal2nVELUVBJm7g6MsYsT1MhyKo4rDQK0uWmrwQ0=";

  cargoBuildFlags = [
    "-p"
    "herdr-core"
  ];

  nativeBuildInputs = [
    zig_0_16
    lld
  ];

  # GNU ld 2.46 rejects overlapping FDEs in the Zig-built Ghostty archive.
  RUSTFLAGS = "-C link-arg=-fuse-ld=lld";

  # Cargo invokes Zig through ghostty-vt's build.rs, not through Nix's Zig phases.
  dontUseZigConfigure = true;
  dontUseZigBuild = true;
  dontUseZigCheck = true;
  dontUseZigInstall = true;

  postUnpack = ''
    rm -rf "$sourceRoot/vendor/ghostty"
    mkdir -p "$sourceRoot/vendor/ghostty"
    cp -R ${ghostty}/. "$sourceRoot/vendor/ghostty/"
    chmod -R u+w "$sourceRoot/vendor/ghostty"
  '';

  preBuild = ''
    export ZIG_GLOBAL_CACHE_DIR="$TMPDIR/zig-cache"
    mkdir -p "$ZIG_GLOBAL_CACHE_DIR"
    ln -s ${zigDeps} "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

  # The test suite spawns PTYs and long-running servers; the install check
  # below is enough of a smoke test.
  doCheck = false;

  # Upstream's installer puts `hc` beside herdr-core; agents and herdr-app
  # mods call it by that name.
  postInstall = ''
    ln -s herdr-core "$out/bin/hc"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/hc" --version | grep -q '^hc ${version}'
    runHook postInstallCheck
  '';

  meta = {
    description = "Terminal server for coding agents, used by herdr-app";
    homepage = "https://github.com/herdrdev/herdr-core";
    license = lib.licenses.asl20;
    mainProgram = "hc";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
