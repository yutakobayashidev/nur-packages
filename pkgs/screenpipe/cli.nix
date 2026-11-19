{
  lib,
  stdenv,
  rustPlatform,
  screenpipeSrc,
  alsa-lib,
  bun,
  bzip2,
  cmake,
  dbus,
  ffmpeg,
  grim,
  libpulseaudio,
  libsamplerate,
  libgbm,
  libglvnd,
  libx11,
  libxcb,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  libxtst,
  makeWrapper,
  mesa,
  oniguruma,
  onnxruntime,
  openblas,
  openssl,
  pipewire,
  pkg-config,
  SDL2,
  sqlite,
  tesseract,
  wayland,
  webrtc-audio-processing,
  xdotool,
  xz,
  zlib,
}:

let
  openblasCompat = stdenv.mkDerivation {
    pname = "screenpipe-openblas-compat";
    inherit (openblas) version;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out
      ln -s ${lib.getDev openblas}/include $out/include
      mkdir -p $out/lib
      ln -s ${openblas}/lib/libopenblas.so $out/lib/liblibopenblas.so
    '';
  };
in
rustPlatform.buildRustPackage {
  pname = "screenpipe-cli";
  version = "0.4.27";
  src = screenpipeSrc;

  cargoHash = "sha256-b3miF45Kwt1+/7Scxw8aCmHGZFP1RwuHEuqaQ4AXe7c=";
  cargoBuildFlags = [
    "-p"
    "screenpipe-engine"
    "--bin"
    "screenpipe"
  ];
  cargoInstallFlags = [
    "-p"
    "screenpipe-engine"
    "--bin"
    "screenpipe"
  ];

  nativeBuildInputs = [
    bun
    cmake
    makeWrapper
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    SDL2
    alsa-lib
    bzip2
    dbus
    ffmpeg
    libgbm
    libpulseaudio
    libsamplerate
    libglvnd
    libx11
    libxcb
    libxcursor
    libxext
    libxi
    libxinerama
    libxrandr
    libxtst
    mesa
    oniguruma
    onnxruntime
    openblasCompat
    openssl
    pipewire
    sqlite
    tesseract
    wayland
    webrtc-audio-processing
    xdotool
    xz
    zlib
  ];

  env = {
    NIX_CFLAGS_COMPILE = "-D_GNU_SOURCE";
    OPENBLAS_PATH = openblasCompat;
    ORT_LIB_LOCATION = "${onnxruntime}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";
    ORT_STRATEGY = "system";
  };

  postInstall = ''
    wrapProgram $out/bin/screenpipe \
      --prefix PATH : ${
        lib.makeBinPath [
          bun
          ffmpeg
          grim
          tesseract
          xdotool
        ]
      }
  '';

  postFixup = ''
    patchelf --add-rpath ${openblas}/lib $out/bin/.screenpipe-wrapped
  '';

  doCheck = false;

  meta = {
    description = "Local-first screen and audio capture engine for AI workflows";
    homepage = "https://screenpi.pe";
    changelog = "https://github.com/screenpipe/screenpipe/releases/tag/v0.4.27";
    license = {
      shortName = "screenpipe-commercial";
      fullName = "Screenpipe Commercial License";
      free = false;
      url = "https://github.com/screenpipe/screenpipe/blob/2c00d135fde56a45ebc89a95ab589892e719fd88/LICENSE.md";
    };
    mainProgram = "screenpipe";
    platforms = [ "x86_64-linux" ];
  };
}
