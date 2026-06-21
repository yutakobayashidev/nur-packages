{
  lib,
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonApplication rec {
  pname = "whichllm";
  version = "0.5.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Andyyyy64";
    repo = "whichllm";
    rev = "v${version}";
    hash = "sha256-B/pJyRMJBkxs9ANGVDN+ub8yKCOxtNQ+uHsy7i71BOE=";
  };

  build-system = [ python3Packages.hatchling ];

  dependencies = [
    python3Packages.typer
    python3Packages.rich
    python3Packages.httpx
    python3Packages.psutil
    python3Packages.dbgpu
    python3Packages.thefuzz
    python3Packages.nvidia-ml-py
  ];

  meta = with lib; {
    description = "Find the best local LLM that actually runs on your hardware";
    homepage = "https://github.com/Andyyyy64/whichllm";
    license = licenses.mit;
    mainProgram = "whichllm";
  };
}
