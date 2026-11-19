{
  lib,
  pkgs,
}:

let
  version = "0.4.25";

  buzz-unwrapped = pkgs.stdenvNoCC.mkDerivation {
    pname = "buzz-unwrapped";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/block/buzz/releases/download/v${version}/Buzz_${version}_amd64.deb";
      hash = "sha256-Wy6ybnXcG+IBVOBEomj3HAzu16VgoDKnP5du1D1s/oc=";
    };

    nativeBuildInputs = [ pkgs.dpkg ];

    unpackPhase = "dpkg-deb -x $src .";
    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;
    dontPatchELF = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r usr/. $out/

      runHook postInstall
    '';
  };
in
pkgs.buildFHSEnv {
  pname = "buzz";
  inherit version;
  runScript = "${buzz-unwrapped}/bin/buzz-desktop";

  profile = ''
    export GST_PLUGIN_SYSTEM_PATH_1_0=/usr/lib/gstreamer-1.0
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
  '';

  targetPkgs =
    pkgs:
    with pkgs;
    [
      webkitgtk_4_1
      gtk3
      glib
      glib-networking
      libsoup_3
      cairo
      pango
      gdk-pixbuf
      harfbuzz
      librsvg
      atk
      at-spi2-atk
      at-spi2-core
      gsettings-desktop-schemas
      dconf
      openssl
      zlib
      curl
      nss
      nspr
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-libav
      gst_all_1.gst-plugins-ugly
      libGL
      libglvnd
      mesa
      libdrm
      libx11
      libxext
      libxrender
      libxi
      libxcursor
      libxdamage
      libxfixes
      libxcomposite
      libxrandr
      libxtst
      libxcb
      wayland
      libxkbcommon
      fontconfig
      freetype
      alsa-lib
      libpulseaudio
      pipewire
      dbus
      libnotify
      expat
      libffi
      pcre2
    ];

  extraInstallCommands = ''
    mkdir -p $out/share
    cp -a ${buzz-unwrapped}/share/applications $out/share/
    cp -a ${buzz-unwrapped}/share/icons $out/share/
    for desktopFile in $out/share/applications/*.desktop; do
      [ -e "$desktopFile" ] || continue
      substituteInPlace "$desktopFile" \
        --replace-quiet "Exec=buzz-desktop" "Exec=buzz" \
        --replace-quiet "Exec=/usr/bin/buzz-desktop" "Exec=buzz"
    done
  '';

  meta = {
    description = "Desktop app for private voice interaction with AI agents";
    homepage = "https://github.com/block/buzz";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.asl20;
    mainProgram = "buzz";
    platforms = [ "x86_64-linux" ];
  };
}
