{
  lib,
  rustPlatform,
  fetchFromGitHub,
  onnxruntime,
}:
rustPlatform.buildRustPackage rec {
  pname = "headroom-ai";
  version = "0.22.2";

  src = fetchFromGitHub {
    owner = "chopratejas";
    repo = "headroom";
    rev = "v${version}";
    hash = "sha256-D8lSYWKQs0FfuDCC5yapj9+XI8o8B6xuu5Uh1J/8GTw=";
  };

  cargoHash = "sha256-WQBvil0bsS6/Z6b+uRauwOQq4VZ57VwAoghcyFdVgLE=";

  buildInputs = [ onnxruntime ];

  env = {
    ORT_STRATEGY = "system";
    ORT_PREFER_DYNAMIC_LINK = "1";
    ORT_LIB_LOCATION = "${onnxruntime}";
    ORT_INCLUDE_LOCATION = "${onnxruntime.dev}/include";
  };

  meta = with lib; {
    description = "Context optimization layer for LLM applications";
    homepage = "https://github.com/chopratejas/headroom";
    license = licenses.asl20;
    mainProgram = "headroom-proxy";
    platforms = platforms.linux;
  };
}
