{
  lib,
  fetchFromGitHub,
  git,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "cccc-moznion";
  version = "1.8.5";

  src = fetchFromGitHub {
    owner = "moznion";
    repo = "cccc";
    tag = "v${version}";
    hash = "sha256-8QfPfyg7Y05wbiWnLyGLpDe4F1SkvTJuZPLn+5ZQIpw=";
  };

  cargoHash = "sha256-iWzC0LORv4uxacv8DrMlVB8XUK4cktrazoAv+IQYwGg=";

  nativeBuildInputs = [ rustPlatform.bindgenHook ];
  nativeCheckInputs = [ git ];

  meta = {
    description = "Measure cognitive and cyclomatic complexity across multiple languages";
    homepage = "https://github.com/moznion/cccc";
    license = lib.licenses.mit;
    mainProgram = "cccc";
  };
}
