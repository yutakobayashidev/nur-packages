{
  lib,
  stdenv,
  fetchFromGitHub,
  tree-sitter,
}:

stdenv.mkDerivation {
  pname = "tree-sitter-moonbit-grammar";
  version = "0-unstable-2026-07-06";

  src = fetchFromGitHub {
    owner = "moonbitlang";
    repo = "tree-sitter-moonbit";
    rev = "fe025ee46c206a36aa99f0c8444cb730abe5473e";
    hash = "sha256-8udCI1HLGT5uDq7K9X4FcME100OXxoMSejtFl+HFgzY=";
  };

  buildInputs = [ tree-sitter ];

  buildPhase = ''
    runHook preBuild
    cd src
    $CC -shared -fPIC -o parser.so parser.c scanner.c -I .
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/parser $out/queries/moonbit
    cp parser.so $out/parser/moonbit.so
    cp ../queries/*.scm $out/queries/moonbit/
    runHook postInstall
  '';

  meta = {
    description = "Tree-sitter grammar for MoonBit";
    homepage = "https://github.com/moonbitlang/tree-sitter-moonbit";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
}
