# Imported from https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/jp/jportaudio/package.nix
{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  cmake,
  ninja,
  gradle,
  jdk,
  portaudio,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jportaudio";
  version = "0-unstable-2026-02-13";

  src = fetchFromGitHub {
    owner = "philburk";
    repo = "portaudio-java";
    rev = "d185a5322ecbe8bd209e14e7341fb73d0c7d2cc3";
    hash = "sha256-XG1bJm0hDSF4cE2OvQ5bvN8pmaKwIl9zDlsRCnTXnLc=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    gradle
    jdk
  ];

  buildInputs = [ portaudio ];

  env = {
    JAVA_HOME = jdk.home;
    GRADLE_HOME = gradle;
  };

  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];

  postBuild = ''
    : "''${cmakeBuildDir:=build}"
    nativeLibDir="$PWD/native-libs"
    mkdir -p "$nativeLibDir"

    if [ -d "$cmakeBuildDir" ]; then
      find "$cmakeBuildDir" -type f -name '*.so' -exec cp -v -n {} "$nativeLibDir/" \;
    fi

    export GRADLE_USER_HOME="$(mktemp -d)"
    sourceRoot="$NIX_BUILD_TOP/source"
    ( cd "$sourceRoot" && gradle --no-daemon -Djava.library.path="$nativeLibDir" assemble )
  '';

  postInstall = ''
    : "''${cmakeBuildDir:=build}"
    sourceRoot="$NIX_BUILD_TOP/source"
    mkdir -p "$out/share/java"

    if ls "$sourceRoot"/build/libs/*.jar >/dev/null 2>&1; then
      cp "$sourceRoot"/build/libs/*.jar "$out/share/java/"
    fi

    if [ ! -e "$out/lib/libjportaudio.so" ]; then
      candidate=$(ls "$out"/lib/libjportaudio*.so* 2>/dev/null | sort -V | tail -n1 || true)
      ln -s "$(basename "$candidate")" "$out/lib/libjportaudio.so"
    fi
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Java wrapper for PortAudio audio library";
    homepage = "https://github.com/philburk/portaudio-java";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
