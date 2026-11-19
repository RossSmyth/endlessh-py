{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.endlessh-py;
in
{
  options.services.endlessh-py = {
    enable = lib.mkEnableOption "endlessh-py";

    package = lib.mkPackageOption pkgs "endlessh-py" { };

    port = lib.mkOption {
      type = lib.types.int;
      default = 22;
      description = "Port to bind socket to";
    };

    openFirewall = lib.mkEnableOption "openFirewall";
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.sockets.endlessh-py = {
      description = "endlessh-py socket";
      wantedBy = [ "sockets.target" ];
      socketConfig = {
        Accept = false;
        ListenStream = [ cfg.port ];
      };
    };

    systemd.services.endlessh-py = {
      description = "endlessh-py SSH tarpit";

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = 5;

        RuntimeDirectory = "endlessh-py";
        RootDirectory = "/run/endlessh-py";
        BindReadOnlyPaths = [
          builtins.storeDir
        ];

        # Important bits
        DynamicUser = true;
        CapabilityBoundingSet = [ "" ];
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateIPC = true;
        PrivatePIDs = true;
        ProtectHostname = true;
        RestrictNamespaces = true;
        PrivateUsers = true;

        # Depth
        SocketBindDeny = "any";
        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        ProtectSystem = "strict";
        ProtectProc = "invisible";
        ProtectClock = true;
        ProtectKernelTunables = true;
        RemoveIPC = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };
  };
}
