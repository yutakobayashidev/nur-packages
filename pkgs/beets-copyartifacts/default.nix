{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  beets,
  setuptools,
}:

buildPythonPackage rec {
  pname = "beets-copyartifacts3";
  version = "0.1.6";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "adammillerio";
    repo = "beets-copyartifacts";
    rev = "v${version}";
    hash = "sha256-fMnXuMwxylO9Q7EFPpkgwwNeBuviUa8HduRrqrqdMaI=";
  };

  build-system = [ setuptools ];

  dependencies = [ beets ];

  postPatch = ''
    rm -f Makefile
  '';

  doCheck = false;

  pythonImportsCheck = [ "beetsplug.copyartifacts" ];

  meta = with lib; {
    description = "beets plugin to copy non-music files to import path";
    homepage = "https://github.com/adammillerio/beets-copyartifacts";
    license = licenses.mit;
  };
}
