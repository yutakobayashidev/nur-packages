{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "mcp-searxng";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "mcp-searxng";
    rev = "v${version}";
    hash = "sha256-R6pJ5fJ0V46rY7XZBhf7RDK5I3kVlqbbaxqtfm6XKkU=";
  };

  npmDepsHash = "sha256-3Mbhmd9Rw6k5OcbcfJf7JKXtgpke5GiDkf0CqY9YYAw=";

  meta = {
    description = "MCP Server for SearXNG";
    homepage = "https://github.com/ihor-sokoliuk/mcp-searxng";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "mcp-searxng";
  };
}
