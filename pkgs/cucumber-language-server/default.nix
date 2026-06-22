{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "cucumber-language-server";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "cucumber";
    repo = "language-server";
    rev = "v${version}";
    hash = "sha256-GGPajuy1pOidi7Ux+i7CfLjsRT7vsLQRj1IzTXBWPQY=";
  };

  npmDepsHash = "sha256-sjoj7OLZcvFf0g/6kjhWgt/bUNKbbvYqBszNDYHxf4A=";

  npmInstallFlags = [ "--ignore-scripts" ];
  npmRebuildFlags = [ "--ignore-scripts" ];

  npmBuildScript = "build";

  meta = {
    description = "Language server for Cucumber";
    homepage = "https://github.com/cucumber/language-server";
    license = lib.licenses.mit;
    mainProgram = "cucumber-language-server";
  };
}
