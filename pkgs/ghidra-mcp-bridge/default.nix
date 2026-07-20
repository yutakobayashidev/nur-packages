{
  lib,
  fetchurl,
  makeWrapper,
  python3,
  stdenvNoCC,
  unzip,
}:

let
  pythonEnv = python3.withPackages (ps: [
    ps.mcp
    ps.requests
  ]);
in
stdenvNoCC.mkDerivation rec {
  pname = "ghidra-mcp-bridge";
  version = "1.1";

  src = fetchurl {
    url = "https://github.com/LaurieWired/GhidraMCP/releases/download/${version}/GhidraMCP-release-1-1.zip";
    hash = "sha256-WHwlwo8sV7t9irFKg0gOOzL04wvfhf+WElRVa9lAnus=";
  };

  dontUnpack = true;
  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/share/ghidra-mcp"
    unzip -p "$src" bridge_mcp_ghidra.py > "$out/share/ghidra-mcp/bridge_mcp_ghidra.py"
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
