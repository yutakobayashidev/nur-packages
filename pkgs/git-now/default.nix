{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "git-now";
  version = "0.1.1.0";

  src = fetchFromGitHub {
    owner = "iwata";
    repo = "git-now";
    rev = "v${version}";
    hash = "sha256-r1Xl9i2SXkaxVBjChdsnqgsex8f+AyVsPbBMwLHOVpM=";
  };

  shFlagsSrc = fetchFromGitHub {
    owner = "nvie";
    repo = "shFlags";
    rev = "2fb06af13de884e9680f14a00c82e52a67c867f1";
    hash = "sha256-Xp+2MOIRpe06DoD4+QV8pE+oEdgFQB7/J0jgfV/6WqQ=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/git-now

    cp $shFlagsSrc/src/shflags $out/share/git-now/

    cp gitnow-common $out/bin/
    ln -s $out/share/git-now/shflags $out/bin/gitnow-shFlags

    cp git-now $out/bin/
    cp git-now-add $out/bin/
    cp git-now-grep $out/bin/
    cp git-now-push $out/bin/
    cp git-now-rebase $out/bin/

    chmod +x $out/bin/git-now*

    for script in $out/bin/git-now $out/bin/git-now-add $out/bin/git-now-grep $out/bin/git-now-push $out/bin/git-now-rebase; do
      wrapProgram "$script" \
        --prefix PATH : "${lib.makeBinPath [ git ]}"
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Command-line tool for light and temporary commits";
    homepage = "https://github.com/iwata/git-now";
    license = licenses.asl20;
    mainProgram = "git-now";
    platforms = platforms.unix;
  };
}
