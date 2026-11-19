{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage rec {
  pname = "oracle";
  version = "0.16.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@steipete/oracle/-/oracle-${version}.tgz";
    hash = "sha256-fQuFb2hfEDbrAO+vRj5SiIf1HZAH/l2hlXsQvben4gc=";
  };

  sourceRoot = "package";
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-90G+92Lg7zyi2qWpvHgSit6CuI+gTDCyWAGYCDW2SM8=";
  npmDepsFetcherVersion = 2;
  dontNpmBuild = true;
  npmPackFlags = [ "--ignore-scripts" ];

  meta = with lib; {
    description = "CLI and MCP server for delegating prompts to ChatGPT";
    homepage = "https://github.com/steipete/oracle";
    license = licenses.mit;
    mainProgram = "oracle";
    platforms = platforms.unix;
  };
}
