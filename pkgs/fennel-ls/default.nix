{
  lib,
  stdenv,
  lua,
  luaPackages,
  pandoc,
  fetchFromSourcehut,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fennel-ls";
  version = "e355534d8d9d9168dc9d0fd19ba59d4b69d3e776";

  src = fetchFromSourcehut {
    owner = "~xerool";
    repo = "fennel-ls";
    rev = finalAttrs.version;
    hash = "sha256-6ZbGRTBBRktudGVBZ+UMn8l0+wKa8f5dg7UOwLhOT7E=";
  };

  nativeBuildInputs = [
    pandoc
  ];

  buildInputs = [
    lua
    luaPackages.fennel
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Language server for Fennel";
    homepage = "https://git.sr.ht/~xerool/fennel-ls";
    license = licenses.mit;
    mainProgram = "fennel-ls";
  };
})
