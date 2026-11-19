{
  fetchurl,
  lib,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "ptrlib";
  version = "3.1.2";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/89/40/e2657f8b8fb39504b9d7979ddf08fe284c60b027a0710ad6c235d6dae401/ptrlib-${version}-py3-none-any.whl";
    hash = "sha256-jYP3q/wosHNbnHUZ9gq/AkPl97+JwSL21JI4mH2vooU=";
  };

  dependencies = [ python3Packages.pycryptodome ];

  # The wheel advertises ptrlib.__init__:main, but that function does not
  # exist. ptrlib is consumed as a Python library, so omit the broken wrapper.
  postInstall = ''
    rm "$out/bin/ptrlib"
  '';

  pythonImportsCheck = [ "ptrlib" ];

  meta = {
    description = "Python library for CTF players";
    homepage = "https://github.com/ptr-yudai/ptrlib";
    license = lib.licenses.mit;
  };
}
