# nix-nvim — repoman-enabled devenv.
#
# RepoMan is always on. The tracked .repoman/project.toml selects its manager
# roster. This base project uses copyroom and gitman.
{ ... }:

{
  repoman.enable = true;

  # Devman bootstraps its central declaration on the first shell entry and
  # reconciles the machine-local links and agent pool on the next entry.
  devman = {
    enable = true;
    project = "nix-nvim";
    groups = [ "base" ];
  };

  # A Python venv hosts the manager CLIs (copyroom, gitman) that repoman-sync
  # installs from repoman.lock — required even though this project isn't Python.
  languages.python = {
    enable = true;
    venv.enable = true;
    uv.enable = true;
  };

  # devman — the automation plane (CONCEPT.md §5), with the direct task shape
  # (like nix-desktop): this repository has no Python suite, so the gate is the
  # flake. `--no-build` type-checks every option without realising a derivation
  # (the fast one); dropping the flag is the gate.
  # https://devenv.sh/tasks/
  tasks = {
    "base:check".exec = "nix flake check --no-build";
    "base:test".exec = "nix flake check";
  };
}
