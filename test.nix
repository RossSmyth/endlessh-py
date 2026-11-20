let
  inputs = import ./npins;
  pkgs = import inputs.nixpkgs { };

  inherit (pkgs) testers;
in
testers.runNixOSTest {
  name = "endlessh-py-tests";
  node.pkgsReadOnly = false;

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

    server.wait_for_open_port(2047)
    client.execute("nc -dvW5 server 2047")
    client.sleep(2)
  '';
}
