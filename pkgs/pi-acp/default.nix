{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  pi-coding-agent,
}:

buildNpmPackage rec {
  pname = "pi-acp";
  version = "0.0.31";

  src = fetchFromGitHub {
    owner = "svkozak";
    repo = "pi-acp";
    rev = "v${version}";
    hash = "sha256-bM3V/3fxkY2Ib+OyfT82StIIRSLXGDuYUbt1CZKpTuo=";
  };

  npmDepsHash = "sha256-qN+b/tMbnJLkWjotl3XrA0nfZ3KT/mT6gM+n3Qiz8Wk=";

  meta = {
    description = "ACP adapter for pi coding agent";
    homepage = "https://github.com/svkozak/pi-acp";
    license = lib.licenses.mit;
    inherit (pi-coding-agent.meta) platforms;
    mainProgram = "pi-acp";
  };
}
