# Imported from https://github.com/MiyakoMeow/nur-packages/blob/main/pkgs/by-name/be/beatoraja/package.nix
{
  lib,
  stdenv,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems,
  unzip,
  jdk,
  openjfx,
  gtk3,
  gnome-themes-extra,
  colord-gtk,
  xrandr,
  libxrandr,
  ffmpeg,
  jportaudio,
  javaPackageWithJavaFX ? jdk.override {
    enableJavaFX = true;
    openjfx_jdk = openjfx.override {
      featureVersion = "21";
    };
  },
  overrideDerivation ? null,
}:

let
  jportaudioClassPath = ":${jportaudio}/share/java/*";
  jportaudioLibPath = "-Djava.library.path=${jportaudio}/lib";
in
stdenv.mkDerivation (finalAttrs: {
  pname = if overrideDerivation != null then overrideDerivation.pname else "beatoraja";

  beatorajaVersion = "0.8.8";
  version =
    if overrideDerivation != null then
      overrideDerivation.version
    else
      finalAttrs.beatorajaVersion;

  src = fetchurl {
    url = "https://www.mocha-repository.info/download/beatoraja${finalAttrs.beatorajaVersion}-modernchic.zip";
    hash = "sha256-yJwokOldNCUdvPtXqy1OL2ESGp446/aZBQevetGlp7Q=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    unzip
    copyDesktopItems
  ];

  buildInputs = [
    javaPackageWithJavaFX
    gtk3
    gnome-themes-extra
    colord-gtk
    xrandr
    libxrandr
    ffmpeg
    jportaudio
  ];

  JAVA_HOME = javaPackageWithJavaFX.home;

  unpackPhase = ''
    runHook preUnpack

    unzip -qq -o $src
    mv beatoraja${finalAttrs.beatorajaVersion}-modernchic/* .
    rmdir beatoraja${finalAttrs.beatorajaVersion}-modernchic

    ${
      if overrideDerivation != null then
        ''
          find ${overrideDerivation} -name "*.jar" -type f | while read -r jar; do
            cp "$jar" .
          done
        ''
      else
        ""
    }

    if [ ! -f ${finalAttrs.pname}.jar ]; then
      echo "ERROR: ${finalAttrs.pname}.jar not found after unpacking"
      find . -type f
      exit 1
    fi

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,${finalAttrs.pname}-ori,share/beatoraja}

    find . -maxdepth 1 -type f -print0 | xargs -0 -I{} cp -- {} $out/${finalAttrs.pname}-ori/
    rm $out/${finalAttrs.pname}-ori/*.bat
    rm $out/${finalAttrs.pname}-ori/*.command
    rm $out/${finalAttrs.pname}-ori/*.dll
    find . -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -I{} cp -r -- {} $out/share/${finalAttrs.pname}/

    cat > $out/bin/${finalAttrs.pname} <<EOF
    #!${stdenv.shell}
    export JAVA_HOME="${javaPackageWithJavaFX.home}"
    export _JAVA_OPTIONS='-Dsun.java2d.opengl=true -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'

    USER_DATA_DIR="\$HOME/.local/share/${finalAttrs.pname}"
    mkdir -p "\$USER_DATA_DIR"

    for dir in $out/share/${finalAttrs.pname}/*/; do
      dir_name=\$(basename "\$dir")
      target_dir="\$USER_DATA_DIR/\$dir_name"

      if [ ! -d "\$target_dir" ]; then
        echo "Initializing directory: \$dir_name"
        cp -r --no-preserve=all "\$dir" "\$target_dir"
      fi
    done

    RUNTIME_DIR=\$(mktemp -d -t ${finalAttrs.pname}.XXX)

    config_files=(
      "beatoraja_log.xml"
      "config_sys.json"
      "songdata.db"
      "songinfo.db"
    )

    for cfg in "\''${config_files[@]}"; do
      user_cfg="\$USER_DATA_DIR/\$cfg"
      if [ -f "\$user_cfg" ]; then
        ln -sf "\$user_cfg" "\$RUNTIME_DIR/"
      fi
    done

    for dir in "\$USER_DATA_DIR"/*/; do
      dir_name=\$(basename "\$dir")
      ln -sfT "\$dir" "\$RUNTIME_DIR/\$dir_name"
    done

    ln -sf $out/${finalAttrs.pname}-ori/${finalAttrs.pname}.jar "\$RUNTIME_DIR/"

    cleanup() {
      echo "Syncing config files back to user directory..."

      for cfg in "\''${config_files[@]}"; do
        runtime_cfg="\$RUNTIME_DIR/\$cfg"
        if [ -f "\$runtime_cfg" ]; then
          cp -f "\$runtime_cfg" "\$USER_DATA_DIR/"
        fi
      done

      find "\$RUNTIME_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
        dir_name=\$(basename "\$dir")
        user_dir="\$USER_DATA_DIR/\$dir_name"

        if [ ! -d "\$user_dir" ]; then
          echo "Copying new directory: \$dir_name to user data"
          cp -r --no-preserve=all "\$dir" "\$user_dir"
        fi
      done
      rm -rf "\$RUNTIME_DIR"
    }
    trap cleanup EXIT

    cd "\$RUNTIME_DIR"
    "${javaPackageWithJavaFX}/bin/java" -Xms1g -Xmx4g \
      -XX:+UseZGC -XX:+DisableExplicitGC \
      -XX:+TieredCompilation -XX:+UseNUMA -XX:+AlwaysPreTouch \
      -XX:+UseLargePages \
      -XX:-UsePerfData -XX:+UseThreadPriorities -XX:+ShowCodeDetailsInExceptionMessages \
      ${jportaudioLibPath} \
      -cp ${finalAttrs.pname}.jar${jportaudioClassPath}:ir/* \
      bms.player.beatoraja.MainLoader "\$@"
    EOF

    chmod +x $out/bin/${finalAttrs.pname}

    copyDesktopItems

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      desktopName = finalAttrs.pname;
      exec = finalAttrs.pname;
      comment = finalAttrs.meta.description;
      mimeTypes = [ "application/java" ];
      categories = [ "Game" ];
      terminal = false;
    })
  ];

  preferLocalBuild = true;

  meta =
    if overrideDerivation != null then
      overrideDerivation.meta
    else
      {
        description = "Modern BMS player";
        homepage = "https://www.mocha-repository.info/download.php";
        license = lib.licenses.gpl3;
        mainProgram = finalAttrs.pname;
      };
})
