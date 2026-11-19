let
  pkgs = import <nixpkgs> {
    overlays = [
      (import ./.)
    ];
  };

  inherit (pkgs) testers;
in
testers.runNixOSTest {
  name = "endlessh-py-tests";

  nodes = {
    server = {
      imports = [
        ./module.nix
      ];
      services.endlessh-py = {
        enable = true;
        openFirewall = true;
      };
    };

    client =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          netcat
        ];
      };
  };

  testScript = ''
    start_all()

    server.wait_for_open_port(22)
    server.wait_for_unit("endlessh-py.service")
    print(client.execute("nc -dvW5 server 22"))
  '';
}
