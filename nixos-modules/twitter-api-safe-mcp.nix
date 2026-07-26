{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.twitter-api-safe-mcp;
  settingsFormat = pkgs.formats.json { };
  settingsFile = settingsFormat.generate "twitter-api-safe-mcp-settings.json" cfg.settings;
in
{
  options.services.twitter-api-safe-mcp = {
    enable = lib.mkEnableOption "Twitter API Safe Relay and MCP server";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/twitter-api-safe-mcp { };
      defaultText = lib.literalExpression "pkgs.twitter-api-safe-mcp";
      description = "The twitter-api-safe-mcp package to use.";
    };

    settings = lib.mkOption {
      inherit (settingsFormat) type;
      default = { };
      description = ''
        Settings written to the JSON file passed to twitter-api-safe-mcp.
        The generated file is stored in the Nix store; do not put secrets in
        this option.
      '';
      example = lib.literalExpression ''
        {
          profiles = [
            {
              name = "account1";
              browser = {
                type = "cdp";
                browserType = "chromium";
                cdpEndpoint = "http://127.0.0.1:9224";
              };
            }
          ];
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.twitter-api-safe-mcp.settings = {
      hostname = lib.mkDefault "127.0.0.1";
      logger.level = lib.mkDefault "info";
      port = lib.mkDefault 3000;
      dashboard = lib.mkDefault true;
      mcp.transport = lib.mkDefault "http";
      profiles = lib.mkDefault [ ];
    };

    assertions = [
      {
        assertion = cfg.settings.profiles != [ ];
        message = "services.twitter-api-safe-mcp.settings.profiles must contain at least one profile";
      }
      {
        assertion = cfg.settings.mcp.transport == "http";
        message = "services.twitter-api-safe-mcp only supports the HTTP MCP transport";
      }
    ];

    systemd.services.twitter-api-safe-mcp = {
      description = "Twitter API Safe Relay and MCP server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      unitConfig = {
        StartLimitIntervalSec = "5m";
        StartLimitBurst = 20;
      };
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} ${settingsFile}";
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}
