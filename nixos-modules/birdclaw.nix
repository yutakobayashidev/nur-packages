{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.birdclaw;
  currentSystemUser = config._module.args.currentSystemUser or null;
in
{
  options.services.birdclaw = {
    enable = lib.mkEnableOption "Birdclaw local Twitter memory service";

    user = lib.mkOption {
      type = lib.types.str;
      default = if currentSystemUser == null then "birdclaw" else currentSystemUser;
      description = "User account that runs Birdclaw.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/srv/birdclaw";
      description = "Directory used for Birdclaw data and working state.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address Birdclaw binds to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3003;
      description = "Port Birdclaw listens on.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.birdclaw
    ];

    users.users = lib.mkIf (currentSystemUser == null && cfg.user == "birdclaw") {
      birdclaw = {
        isSystemUser = true;
        group = "birdclaw";
        home = cfg.dataDir;
      };
    };

    users.groups = lib.mkIf (currentSystemUser == null && cfg.user == "birdclaw") {
      birdclaw = { };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0700 ${cfg.user} users - -"
    ];

    systemd.services.birdclaw = {
      description = "Birdclaw local Twitter memory";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = {
        HOME =
          if currentSystemUser == null && cfg.user == "birdclaw" then cfg.dataDir else "/home/${cfg.user}";
        BIRDCLAW_HOME = cfg.dataDir;
        BIRDCLAW_ALLOW_REMOTE_WEB = "1";
        BIRDCLAW_HOST = cfg.host;
        BIRDCLAW_PORT = toString cfg.port;
      };

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${pkgs.birdclaw}/bin/birdclaw serve";
        Restart = "always";
        RestartSec = 10;
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };
  };
}
