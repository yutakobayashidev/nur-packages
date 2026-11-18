{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_24,
}:

buildNpmPackage {
  pname = "dsh-codex-subscription";
  version = "3.2.24";

  src = fetchurl {
    url = "https://registry.npmjs.org/dsh-codex-subscription/-/dsh-codex-subscription-3.2.24.tgz";
    hash = "sha256-YYmnI1SthwshbluKlzzj8QFOhg+bixjH1lCZeJwkyYo=";
  };
  nodejs = nodejs_24;
  npmDepsHash = "sha256-w35hPstdh16c3tvtJEg/bV0P2QuR1xgfO6Ms5kosh8w=";
  postPatch = ''
    # Ship upstream's compiled bundle. DSH peers are supplied by the host,
    # so loading the plugin never creates a second copy of host services.
    cp ${./package.json} package.json
    cp ${./package-lock.json} package-lock.json
  '';
  dontNpmBuild = true;
  npmFlags = [ "--omit=dev" ];
  npmPackFlags = [ "--ignore-scripts" ];

  meta = {
    description = "ChatGPT subscription authentication and Codex models for DeepSeek Harness";
    homepage = "https://github.com/WSL043/dsh-codex-subscription";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
