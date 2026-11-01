{ grafanaPlugins, lib }:

grafanaPlugins.grafanaPlugin {
  pname = "tim012432-calendarheatmap-panel";
  version = "1.2.1";
  # Preserve the Grafana catalog's community signature and bundled assets.
  zipHash = "sha256-Yjmpws6vKMp5Yqy+8A2PZHsI7CiJN5gprkGE+BqTQco=";
  meta = {
    description = "GitHub-style daily activity calendar for Grafana";
    license = lib.licenses.mit;
  };
}
