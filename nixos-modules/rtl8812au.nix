{
  config,
  lib,
  ...
}:

let
  cfg = config.hardware.rtl8812au;
in
{
  options.hardware.rtl8812au = {
    enable = lib.mkEnableOption "rtl8812au WiFi driver for Realtek 802.11ac adapters";
  };

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [
      config.boot.kernelPackages.rtl8812au
    ];

    boot.kernelModules = [ "8812au" ];
  };
}