{
  lib,
  stdenv,
  kernel,
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

  makeFlags = [
    "KVER=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall
    install -D px4_drv.ko $out/lib/modules/${kernel.modDirVersion}/misc/px4_drv.ko
    runHook postInstall
  '';

  meta = with lib; {
    description = "Unofficial Linux driver for PLEX PX4/PX5/PX-MLT series ISDB-T/S receivers";
    homepage = "https://github.com/tsukumijima/px4_drv";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}