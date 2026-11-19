{
  lib,
  stdenv,
  kernel,
  kernelModuleMakeFlags,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "px4_drv";
  version = "0.5.6";

  src = fetchFromGitHub {
    owner = "tsukumijima";
    repo = "px4_drv";
    rev = "v0.5.6";
    hash = "sha256-E/hGh2F6xsNHJlf6P5RjfT7vCYtpZC/6opiPqMVEsNk=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  preBuild = ''
    cd driver

    cat > revision.h << 'EOF'
    // revision.h

    #ifndef __REVISION_H__
    #define __REVISION_H__

    #endif
    EOF
  '';

  makeFlags = kernelModuleMakeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(PWD)"
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "INSTALL_MOD_DIR=misc"
  ];

  # Use Kbuild for modules.order, signing, and the certificate aggregateModules needs.
  buildTargets = [ "modules" ];
  installTargets = [ "modules_install" ];

  meta = with lib; {
    description = "Unofficial Linux driver for PLEX PX4/PX5/PX-MLT series ISDB-T/S receivers";
    homepage = "https://github.com/tsukumijima/px4_drv";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}