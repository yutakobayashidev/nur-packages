{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  fetchzip,
  gradle_9,
  jdk25,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  gtk3,
  webkitgtk_4_1,
  glib,
  dbus,
  libsoup_3,
  gst_all_1,
  libGL,
  fontconfig,
  libx11,
  libxcursor,
  libxrandr,
  libxi,
  libxext,
  libxrender,
  libxtst,
}:
let
  # Keep the Gradle distribution aligned with deps.json across nixpkgs revisions.
  gradle = gradle_9.override {
    gradle-unwrapped = gradle_9.unwrapped.overrideAttrs (_: {
      version = "9.8.0";
      src = fetchurl {
        url = "https://services.gradle.org/distributions/gradle-9.8.0-bin.zip";
        hash = "sha256-uv1c6c+uoPvM/chDmhrEL71M2cidyamIIo2KJjmljmw=";
      };
    });
  };
  # Multiplatform metadata tasks require the Native distribution even for JVM builds.
  kotlinNative = fetchzip {
    url = "https://repo.maven.apache.org/maven2/org/jetbrains/kotlin/kotlin-native-prebuilt/2.4.20/kotlin-native-prebuilt-2.4.20-linux-x86_64.tar.gz";
    hash = "sha256-n1LV04bTvHGRhEOQFMKxh9Li2RUG1hl8dU4Cc7JMjrA=";
  };
  runtimeLibraries = [
    stdenv.cc.cc.lib
    gtk3
    webkitgtk_4_1
    glib
    dbus
    libsoup_3
    libGL
    fontconfig
    libx11
    libxcursor
    libxrandr
    libxi
    libxext
    libxrender
    libxtst
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
  ];
  gstPlugins = with gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "flare-social";
  version = "1.7.8";
  src = fetchFromGitHub {
    owner = "flaresocialapp";
    repo = "Flare";
    tag = finalAttrs.version;
    hash = "sha256-78YP5kMV+hGNmeGjq37heWU09HBzOdZ/HPROtXIuzQI=";
  };
  nativeBuildInputs = [
    gradle
    makeWrapper
    copyDesktopItems
  ];
  env.JAVA_HOME = jdk25;
  postPatch = ''
    # The daemon needs Java 25, but does not require a JetBrains-specific API.
    sed -i '/^toolchainVendor=/d' gradle/gradle-daemon-jvm.properties
    cat >> desktopApp/build.gradle.kts <<'GRADLE'
    tasks.register<Copy>("nixRuntime") {
        from(tasks.named("jar"))
        val runtime = configurations.runtimeClasspath.get()
        val groups by lazy {
            runtime.resolvedConfiguration.resolvedArtifacts.associate { it.file to it.moduleVersion.id.group }
        }
        from(runtime) {
            eachFile { name = "''${groups.getValue(file)}-$name" }
        }
        into(layout.buildDirectory.dir("nix-runtime"))
    }
    GRADLE
  '';
  gradleFlags = [
    "--configure-on-demand"
    "-Dorg.gradle.java.installations.auto-download=false"
    "-Dorg.gradle.java.home=${jdk25}"
  ];
  gradleBuildTask = ":desktopApp:nixRuntime";
  gradleUpdateTask = finalAttrs.gradleBuildTask;
  preConfigure = ''
    export HOME="$TMPDIR/flare-home"
    mkdir -p "$HOME"
    export KONAN_DATA_DIR="$HOME/.konan"
    # The commonizer writes caches inside the compiler distribution.
    cp -r --reflink=auto ${kotlinNative} "$HOME/kotlin-native"
    chmod -R u+w "$HOME/kotlin-native"
    gradleFlagsArray+=("-Duser.home=$HOME" "-Pkotlin.native.home=$HOME/kotlin-native")
  '';
  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    pname = finalAttrs.pname;
    data = ./deps.json;
    silent = false;
    useBwrap = false;
  };
  desktopItems = [
    (makeDesktopItem {
      name = "flare-social";
      desktopName = "Flare";
      exec = "flare-social %U";
      icon = "flare-social";
      comment = "Unified social client";
      categories = [ "Network" ];
      mimeTypes = [
        "x-scheme-handler/flare"
        "x-scheme-handler/pixiv"
      ];
    })
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/flare-social
    cp desktopApp/build/nix-runtime/*.jar $out/share/flare-social/
    install -Dm644 desktopApp/resources/ic_launcher.png $out/share/icons/hicolor/512x512/apps/flare-social.png
    makeWrapper ${jdk25}/bin/java $out/bin/flare-social \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibraries} \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${lib.makeSearchPath "lib/gstreamer-1.0" gstPlugins} \
      --add-flags '--enable-native-access=ALL-UNNAMED' \
      --add-flags "-cp '$out/share/flare-social/*' dev.dimension.flare.MainKt"
    runHook postInstall
  '';
  meta = {
    description = "Unified social client for Mastodon, Bluesky, X, Misskey, Nostr, Pixiv, Fanbox and RSS";
    homepage = "https://github.com/flaresocialapp/Flare";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "flare-social";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
      binaryNativeCode
    ];
  };
})
