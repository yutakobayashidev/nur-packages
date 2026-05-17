{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hardware.px4_drv;
  src = pkgs.fetchFromGitHub {
    owner = "tsukumijima";
    repo = "px4_drv";
    rev = "v0.5.6";
    hash = "sha256-E/hGh2F6xsNHJlf6P5RjfT7vCYtpZC/6opiPqMVEsNk=";
  };
in
{
  options.hardware.px4_drv = {
    enable = lib.mkEnableOption "px4_drv ISDB-T/S tuner driver for PLEX PX-W3U4 etc.";
  };

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [
      (config.boot.kernelPackages.callPackage ./../pkgs/px4_drv { })
    ];

    boot.kernelModules = [ "px4_drv" ];

    hardware.firmware = [
      (pkgs.runCommand "px4_drv-firmware" { } ''
        mkdir -p $out/lib/firmware
        cp ${src}/etc/it930x-firmware.bin $out/lib/firmware/it930x-firmware.bin
      '')
    ];

    services.udev.packages = [
      (pkgs.runCommand "px4_drv-udev-rules" { } ''
        mkdir -p $out/etc/udev/rules.d
        cp ${src}/etc/99-px4video.rules $out/etc/udev/rules.d/99-px4video.rules
      '')
    ];
  };
}