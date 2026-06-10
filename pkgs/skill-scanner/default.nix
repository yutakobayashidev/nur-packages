{
  lib,
  python313,
  callPackage,
}:

let
  version = (lib.importJSON ./hashes.json).version;

  src = builtins.fetchTarball {
    url = "https://github.com/cisco-ai-defense/skill-scanner/archive/refs/tags/${version}.tar.gz";
    sha256 = "1my900gc1bjpgd7m4w2mpckz5fqww0s1dvpq9bpcbcb04s9mz4gc";
  };

  pyproject-nix-src = builtins.fetchTarball {
    url = "https://github.com/pyproject-nix/pyproject.nix/archive/ad83f1ead0e78e57b188f35cb57298affb06fc5f.tar.gz";
    sha256 = "10n1bjcwvfc8vqjh4c54pydijw7lyf2xgpidx75cm0mib0hbf4md";
  };

  uv2nix-src = builtins.fetchTarball {
    url = "https://github.com/pyproject-nix/uv2nix/archive/0497ccef038da091002be7c05263a7f27820974f.tar.gz";
    sha256 = "1pf968rhkpxzmy8ajilj4yg8jxdin3y7lw7ris2m9iw3z4v515f9";
  };

  pyproject-build-systems-src = builtins.fetchTarball {
    url = "https://github.com/pyproject-nix/build-system-pkgs/archive/7bff980f37fc24e09dbc986643719900c139bf12.tar.gz";
    sha256 = "0m9ymk1jm4dp3l95hdw10m31bjml1f2qwn7mydkaanp42jag5d9i";
  };

  pyproject-nix-lib = import pyproject-nix-src {
    inherit lib;
  };

  uv2nix-module = import uv2nix-src {
    inherit lib;
    pyproject-nix = pyproject-nix-lib;
  };

  build-systems-overlays = import pyproject-build-systems-src {
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
