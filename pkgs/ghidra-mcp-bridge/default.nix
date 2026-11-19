{
  fetchFromGitHub,
  lib,
  makeWrapper,
  python3,
  stdenvNoCC,
}:

let
  pythonEnv = python3.withPackages (ps: [
    ps.httpx
    ps.mcp
    ps.tenacity
  ]);
in
stdenvNoCC.mkDerivation {
  pname = "ghidra-mcp-bridge";
  version = "1.4-unstable-2026-01-11";

  src = fetchFromGitHub {
    owner = "jethac";
    repo = "GhidraMCP";
    rev = "f7a030ac4b847eb000126ff574ad5d5ccb0d6eb1";
    hash = "sha256-c79PGVa94kmYu/xi1CHabQuXySZMBkwMQApyau6X7Dg=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/share/ghidra-mcp"
    install -Dm644 bridge_mcp_ghidra.py "$out/share/ghidra-mcp/bridge_mcp_ghidra.py"
    makeWrapper "${pythonEnv}/bin/python" "$out/bin/ghidra-mcp-bridge" \
      --add-flags "$out/share/ghidra-mcp/bridge_mcp_ghidra.py"

    runHook postInstall
  '';

  meta = {
    description = "MCP stdio bridge for the GhidraMCP extension";
    homepage = "https://github.com/LaurieWired/GhidraMCP";
    license = lib.licenses.asl20;
    mainProgram = "ghidra-mcp-bridge";
  };
}
