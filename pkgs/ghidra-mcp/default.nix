{
  lib,
  fetchurl,
  ghidra,
}:

ghidra.buildGhidraExtension rec {
  pname = "GhidraMCP";
  version = "1.1";

  src = fetchurl {
    url = "https://github.com/LaurieWired/GhidraMCP/releases/download/${version}/GhidraMCP-release-1-1.zip";
    hash = "sha256-WHwlwo8sV7t9irFKg0gOOzL04wvfhf+WElRVa9lAnus=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$TMPDIR/extract" "$out/lib/ghidra/Ghidra/Extensions"
    unzip -q "$src" -d "$TMPDIR/extract"

    extensionZip="$(find "$TMPDIR/extract" -type f -name '*.zip' -print -quit)"
    if [ -z "$extensionZip" ]; then
      echo "Error: release archive contains no Ghidra extension ZIP" >&2
      exit 1
    fi

    unzip -q "$extensionZip" -d "$out/lib/ghidra/Ghidra/Extensions"
    for extension in "$out/lib/ghidra/Ghidra/Extensions"/*; do
      # The release puts name/description properties in Module.manifest, but
      # Ghidra only accepts MODULE FILE LICENSE entries there.
      : > "$extension/Module.manifest"
      touch "$extension/.dbDirLock"
    done

    runHook postInstall
  '';

  passthru = { inherit ghidra; };

  meta = {
    description = "MCP server for Ghidra that enables LLM-assisted reverse engineering";
    homepage = "https://github.com/LaurieWired/GhidraMCP";
    license = lib.licenses.asl20;
  };
}
