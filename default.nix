final: _:
let
  inherit (final) writers python3Packages;
in
{
  endlessh-py = (
    writers.writePython3Bin "endlessh-py" {
      libraries = [ python3Packages.systemd-python ];
    } (builtins.readFile ./endlessh.py)
  );
}
