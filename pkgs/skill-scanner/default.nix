{
  lib,
  python313,
  callPackage,
  fetchFromGitHub,
}:

let
  version = (lib.importJSON ./hashes.json).version;

  src = fetchFromGitHub {
    owner = "cisco-ai-defense";
    repo = "skill-scanner";
    rev = version;
    hash = "sha256-7JFfkyZgscXuSvjuFjTgHLvyJ7tVcFJPe1euwB4Aydc=";
  };

  pyproject-nix-pkg = callPackage ../pyproject-nix { };
  uv2nix-pkg = callPackage ../uv2nix { };
  pyproject-build-systems-pkg = callPackage ../pyproject-build-systems { };

  pyproject-nix-lib = import "${pyproject-nix-pkg}/pyproject-nix" {
    inherit lib;
  };

  uv2nix-module = import "${uv2nix-pkg}/uv2nix" {
    inherit lib;
    pyproject-nix = pyproject-nix-lib;
  };

  build-systems-overlays = import "${pyproject-build-systems-pkg}/pyproject-build-systems" {
    inherit lib;
    uv2nix = uv2nix-module;
    pyproject-nix = pyproject-nix-lib;
  };

  workspace = uv2nix-module.lib.workspace.loadWorkspace {
    workspaceRoot = src;
  };

  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };

  pyprojectOverrides =
    final: prev:
    let
      addBuildSystem =
        buildSystem: pkg:
        pkg.overrideAttrs (old: {
          nativeBuildInputs =
            (old.nativeBuildInputs or [ ]) ++ final.resolveBuildSystem { "${buildSystem}" = [ ]; };
        });
    in
    {
      cisco-ai-skill-scanner = (addBuildSystem "hatchling" prev.cisco-ai-skill-scanner).overrideAttrs
        (old: {
          nativeBuildInputs =
            (old.nativeBuildInputs or [ ]) ++ final.resolveBuildSystem { hatch-vcs = [ ]; };

          SETUPTOOLS_SCM_PRETEND_VERSION = version;
        });
    };

  pythonSet =
    (callPackage pyproject-nix-lib.build.packages {
      python = python313;
    }).overrideScope
      (
        lib.composeManyExtensions [
          build-systems-overlays.default
          overlay
          pyprojectOverrides
        ]
      );

  venv = pythonSet.mkVirtualEnv "skill-scanner-env" workspace.deps.default;

in
venv.overrideAttrs (old: {
  pname = "skill-scanner";
  inherit version;

  passthru = (old.passthru or { }) // {
    python = python313;
  };

  meta = {
    description = "Security scanner for Agent Skills packages";
    homepage = "https://github.com/cisco-ai-defense/skill-scanner";
    license = lib.licenses.asl20;
    mainProgram = "skill-scanner";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
})
