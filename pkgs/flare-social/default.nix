{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "flare-social";
  version = "1.7.8";

  src = fetchurl {
    url = "https://github.com/DimensionDev/Flare/releases/download/${version}/Flare-${version}.AppImage";
    hash = "sha256-heGvXFAvq/0HpGXwdp4qBhV6pwFs4N6o1/TX9WjhO/A=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/Flare.desktop $out/share/applications/flare-social.desktop
    substituteInPlace $out/share/applications/flare-social.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=flare-social' \
      --replace-fail 'Icon=Flare' 'Icon=flare-social'
    install -Dm644 ${appimageContents}/Flare.png $out/share/icons/hicolor/512x512/apps/flare-social.png
  '';

  meta = {
    description = "Unified social client for Mastodon, Bluesky, X, Misskey, Nostr, Pixiv, Fanbox and RSS";
    homepage = "https://github.com/DimensionDev/Flare";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "flare-social";
  };
}
