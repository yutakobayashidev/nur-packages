{
  lib,
  buildNpmPackage,
  fetchurl,
  makeWrapper,
  nodejs_24,
}:

buildNpmPackage {
  pname = "lazydsh";
  version = "0.2.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/lazydsh/-/lazydsh-0.2.0.tgz";
    hash = "sha256-AAcYDBO75+USJGRfAoGhZd7+EanBIrmdgOPY94zLyEo=";
  };

  nodejs = nodejs_24;
  npmDepsHash = "sha256-3JIUcWU9czyglCVr3l360Z0lN4zpsjIUP7O263yP/pw=";

  postPatch = ''
    # The registry tarball already contains dist; development tools are unnecessary.
    cp ${./package.json} package.json
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;
  npmFlags = [ "--omit=dev" ];
  npmPackFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    # Match llm-agents.nix's dsh workaround for Nixpkgs' Node/V8 build.
    for f in index.js worker/profile-resolution-bootstrap.js; do
      substituteInPlace \
        $out/lib/node_modules/lazydsh/node_modules/@deepseek-ai/dsh-app-boot/lib/$f \
        --replace-fail 'createRequire(import.meta.url)("node-addon-require-builtin")' \
        '{ requireBuiltin: createRequire(import.meta.url) }'
    done

    rm $out/bin/lazydsh
    makeWrapper ${lib.getExe nodejs_24} $out/bin/lazydsh \
      --add-flags "--expose-internals" \
      --add-flags "$out/lib/node_modules/lazydsh/dist/cli.mjs"
  '';

  meta = {
    description = "A lazier terminal UI for DeepSeek Harness";
    homepage = "https://github.com/nuskey8/lazydsh";
    license = lib.licenses.mit;
    mainProgram = "lazydsh";
    platforms = lib.platforms.unix;
  };
}
