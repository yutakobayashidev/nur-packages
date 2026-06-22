{
  stdenv,
  fetchurl,
  nodejs,
  makeWrapper,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "gh-actions-language-server";
  version = "0.3.55";

  src = fetchurl {
    url = "https://registry.npmjs.org/@actions/languageserver/-/languageserver-${version}.tgz";
    hash = "sha256-9qTZ6ld4VmI5GY5FgsCxbJtXeBOo46U9GxAUDYSrLL8=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    # ${pname}/ 配下に押し込むことで、他の node ベース LSP と
    # `lib/package.json` などが競合するのを防ぐ (home.packages の buildEnv 対策)
    mkdir -p $out/lib/${pname} $out/bin
    cp -r * $out/lib/${pname}/

    # mason の旧名 (gh-actions-language-server) と公式名 (actions-languageserver)
    # 両方の binary を提供。lspconfig (`gh_actions_ls`) は前者を呼ぶ
    makeWrapper ${nodejs}/bin/node $out/bin/gh-actions-language-server \
      --add-flags $out/lib/${pname}/dist/cli.bundle.cjs
    makeWrapper ${nodejs}/bin/node $out/bin/actions-languageserver \
      --add-flags $out/lib/${pname}/dist/cli.bundle.cjs

    runHook postInstall
  '';

  meta = {
    description = "GitHub Actions Language Server";
    homepage = "https://github.com/actions/languageservices";
    license = lib.licenses.mit;
    mainProgram = "gh-actions-language-server";
    platforms = lib.platforms.unix;
  };
}
