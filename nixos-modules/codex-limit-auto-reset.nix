{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.codex-limit-auto-reset;
in
{
  options.services.codex-limit-auto-reset = {
    enable = lib.mkEnableOption "automatic redemption of Codex rate-limit reset credits";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/codex-limit-auto-reset { };
      defaultText = lib.literalExpression "pkgs.codex-limit-auto-reset";
      description = "The codex-limit-auto-reset package to use.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      description = "User whose Codex authentication is used.";
      example = "alice";
    };

    codexHome = lib.mkOption {
      type = lib.types.str;
      description = "Directory containing the user's Codex authentication.";
      example = "/home/alice/.codex";
    };

    codexPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.codex;
      defaultText = lib.literalExpression "pkgs.codex";
      description = "The Codex CLI package used to redeem credits.";
    };

    redeemBeforeMinutes = lib.mkOption {
      type = lib.types.ints.positive;
      default = 360;
      description = "Redeem credits this many minutes before expiration.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.hasAttr cfg.user config.users.users;
        message = "services.codex-limit-auto-reset.user must name an existing user";
      }
    ];

    systemd.services.codex-limit-auto-reset = {
      description = "Codex Limit Auto Reset";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      environment = {
        CODEX_BIN = lib.getExe cfg.codexPackage;
        CODEX_HOME = cfg.codexHome;
        REDEEM_BEFORE_MINUTES = toString cfg.redeemBeforeMinutes;
      };
      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = "10s";
        User = cfg.user;
      };
    };
  };
}
