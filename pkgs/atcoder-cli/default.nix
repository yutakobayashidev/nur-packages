{
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_20,
}:
buildNpmPackage {
  pname = "atcoder-cli";
  version = "2.2.0";
  nodejs = nodejs_20;
  npmInstallFlags = [ "--omit=optional" ];
  npmPruneFlags = [ "--omit=optional" ];

  src = fetchFromGitHub {
    owner = "Tatamo";
    repo = "atcoder-cli";
    rev = "f385e71ba270716f5a94e3ed9bd23a24f78799d0";
    hash = "sha256-7pbCTgWt+khKVyMV03HanvuOX2uAC0PL9OLmqly7IWE=";
  };

  npmDepsHash = "sha256-ufG7Fq5D2SOzUp8KYRYUB5tYJYoADuhK+2zDfG0a3ks=";
  npmPackFlags = [ "--ignore-scripts" ];
  NODE_OPTIONS = "--openssl-legacy-provider";
}
