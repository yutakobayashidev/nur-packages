{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  python3,
}:
let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      beautifulsoup4
      mmh3
      msgpack
      packaging
      requests
    ]
  );
in
stdenv.mkDerivation {
  pname = "s3s";
  version = "0.7.0-unstable-2025-08-19";

  src = fetchFromGitHub {
    owner = "frozenpandaman";
    repo = "s3s";
    rev = "732c91e5ac9b82a413f96bc75831996f8cf4f9ea";
    hash = "sha256-o9GOmOin3wTyCL/KNa+WjMSV4RuyWea2lx5iS+57F68=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/s3s $out/bin

    cp s3s.py iksm.py utils.py $out/lib/s3s/

    substituteInPlace $out/lib/s3s/s3s.py \
      --replace-fail \
      'os.path.join(app_path, "config.txt")' \
      'os.path.join(os.getcwd(), "config.txt")'

    makeWrapper ${pythonEnv}/bin/python3 $out/bin/s3s \
      --add-flags "$out/lib/s3s/s3s.py"

    runHook postInstall
  '';

  meta = {
    description = "Splatoon 3 battle stats uploader to stat.ink";
    homepage = "https://github.com/frozenpandaman/s3s";
    license = lib.licenses.gpl3Only;
    mainProgram = "s3s";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
