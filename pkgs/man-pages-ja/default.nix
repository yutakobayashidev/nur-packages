{
  stdenvNoCC,
  fetchurl,
  lib,
  perl,
  groff,
}:

stdenvNoCC.mkDerivation rec {
  pname = "man-pages-ja";
  version = "20251017";

  src = fetchurl {
    url = "https://github.com/linux-jm/manual/releases/download/v${version}/man-pages-ja-${version}.tar.gz";
    sha256 = "sha256-oSWAYYJ1DF+PaDTgh2UDzjrblNNzAS0kk4sEPTQ59hw=";
  };

  nativeBuildInputs = [ perl ];
  buildInputs = [
    groff
  ];

  patchPhase = ''
    cp script/configure.perl{,.orig}
    export LANG=ja_JP.UTF-8
    cat script/configure.perl.orig | \
    sed \
      -e '/until/ i $ans = "y";' \
      -e "s#/usr/share/man#$out/share/man#" \
      -e 's/install -o $OWNER -g $GROUP/install/' \
      >script/configure.perl
  '';

  configurePhase = ''
    set +o pipefail
    yes "" | make config
  '';

  outputDocdev = "out";

  meta = with lib; {
    homepage = "https://linuxjm.sourceforge.io/";
    description = "Japanese version of man-pages";
    platforms = platforms.all;
  };
}
