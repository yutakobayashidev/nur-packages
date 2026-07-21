{
  lib,
  stdenv,
  rustPlatform,
  screenpipeSrc,
  alsa-lib,
  bun,
  bzip2,
  cargo-tauri,
  cmake,
  dbus,
  ffmpeg,
  glib-networking,
  grim,
  gtk3,
  libayatana-appindicator,
  libgbm,
  libglvnd,
  libpulseaudio,
  librsvg,
  libsamplerate,
  libsecret,
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
  nodejs,
  oniguruma,
  onnxruntime,
  openblas,
  openssl,
  pipewire,
  pkg-config,
  SDL2,
  sqlite,
  tesseract,
  tesseract5,
  wayland,
  webkitgtk_4_1,
  webrtc-audio-processing,
  writableTmpDirAsHomeHook,
  wrapGAppsHook3,
  xdotool,
  xz,
  zlib,
  writeShellScript,
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

  nodeModules = stdenv.mkDerivation {
    pname = "screenpipe-app-node-modules";
    version = "2.5.125";
    src = screenpipeSrc;

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;
    dontFixup = true;
    dontPatchShebangs = true;

    buildPhase = ''
      runHook preBuild

      cd apps/screenpipe-app-tauri
      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install \
        --backend=copyfile \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -R node_modules $out

      runHook postInstall
    '';

    outputHash = "sha256-7MdKceQAYnP7MC9YKpEGf+5vkx4kr0p7FoQJFG/M1zo=";
    outputHashMode = "recursive";
  };

  qtFaststart = writeShellScript "qt-faststart" ''
    set -eu
    if [ "$#" -lt 2 ]; then
      echo "usage: qt-faststart input output" >&2
      exit 2
    fi
    exec "$(dirname "$0")/ffmpeg" -y -i "$1" -c copy -movflags faststart "$2"
  '';
in
rustPlatform.buildRustPackage {
  pname = "screenpipe-app";
  version = "2.5.125";
  src = screenpipeSrc;

  cargoRoot = "apps/screenpipe-app-tauri/src-tauri";
  cargoHash = "sha256-/eSWufIXQ7Cmhf3EMs5Pz3B8Tv8sRZlZWTyVT0mfS+o=";
  cargoPatches = [ ./remove-macos-nokhwa.patch ];
  buildAndTestSubdir = "apps/screenpipe-app-tauri";
  cargoBuildFeatures = [ "redact-onnx-cpu" ];

  nativeBuildInputs = [
    bun
    cargo-tauri.hook
    cmake
    makeWrapper
    nodejs
    pkg-config
    rustPlatform.bindgenHook
    wrapGAppsHook3
  ];

  buildInputs = [
    SDL2
    alsa-lib
    bzip2
    dbus
    ffmpeg
    glib-networking
    gtk3
    libayatana-appindicator
    libgbm
    libglvnd
    libpulseaudio
    librsvg
    libsamplerate
    libsecret
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
    webkitgtk_4_1
    webrtc-audio-processing
    xdotool
    xz
    zlib
  ];

  env = {
    CI = "true";
    NIX_CFLAGS_COMPILE = "-D_GNU_SOURCE";
    OPENBLAS_PATH = openblasCompat;
    ORT_LIB_LOCATION = "${onnxruntime}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";
    ORT_STRATEGY = "system";
  };

  configurePhase = ''
    runHook preConfigure

    app=apps/screenpipe-app-tauri
    cp -R ${nodeModules} "$app/node_modules"
    chmod -R u+rw "$app/node_modules"
    chmod -R u+x "$app/node_modules/.bin"
    patchShebangs --build "$app/node_modules"

    cd "$app"
    cp src-tauri/tauri.prod.conf.json src-tauri/tauri.conf.json
    bun -e '
      const path = "src-tauri/tauri.conf.json";
      const config = await Bun.file(path).json();
      config.bundle.createUpdaterArtifacts = false;
      config.plugins.updater.active = false;
      config.plugins.updater.endpoints = [];
      await Bun.write(path, JSON.stringify(config, null, 2));
    '
    bun scripts/gen-skill-content.js

    cp -L ${bun}/bin/bun src-tauri/bun-x86_64-unknown-linux-gnu
    mkdir -p src-tauri/ffmpeg src-tauri/tessdata
    cp -L ${ffmpeg}/bin/ffmpeg src-tauri/ffmpeg/ffmpeg
    cp -L ${ffmpeg}/bin/ffprobe src-tauri/ffmpeg/ffprobe
    cp -L ${qtFaststart} src-tauri/ffmpeg/qt-faststart
    cp -L ${tesseract}/bin/tesseract src-tauri/tesseract
    cp -L ${tesseract5.languages.eng} src-tauri/tessdata/eng.traineddata
    cd ../..

    runHook postConfigure
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${
        lib.makeBinPath [
          bun
          ffmpeg
          grim
          tesseract
          xdotool
        ]
      }
    )
  '';

  postFixup = ''
    patchelf --add-rpath ${openblas}/lib $out/bin/.screenpipe-app-wrapped
  '';

  doCheck = false;

  meta = {
    description = "Local-first desktop memory application";
    homepage = "https://screenpi.pe";
    changelog = "https://github.com/screenpipe/screenpipe/releases/tag/app-v2.5.125";
    license = {
      shortName = "screenpipe-commercial";
      fullName = "Screenpipe Commercial License";
      free = false;
      url = "https://github.com/screenpipe/screenpipe/blob/2c00d135fde56a45ebc89a95ab589892e719fd88/LICENSE.md";
    };
    mainProgram = "screenpipe-app";
    platforms = [ "x86_64-linux" ];
  };
}
