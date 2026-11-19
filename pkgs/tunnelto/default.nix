{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "tunnelto";
  version = "0.1.18";

  src = fetchFromGitHub {
    owner = "agrinman";
    repo = "tunnelto";
    rev = version;
    hash = "sha256-dCHl5EXjUagOKeHxqb3GlAoSDw0u3tQ4GKEtbFF8OSs=";
  };

  # Refresh the TLS crates for supported OpenSSL 3 without changing upstream code.
  cargoPatches = [ ./openssl3.patch ];
  cargoHash = "sha256-ip10wQoNJKjP5wHCQC+LTq9K9CXtQgOJ9NXv1ZehPPo=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  buildAndTestSubdir = "tunnelto";

  meta = with lib; {
    description = "Expose your local web server to the internet with a public URL";
    homepage = "https://github.com/agrinman/tunnelto";
    license = licenses.mit;
    mainProgram = "tunnelto";
  };
}
