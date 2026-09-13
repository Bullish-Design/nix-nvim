# nix-nvim — repoman-enabled devenv.
#
# RepoMan is always on. This base template wires the two language-agnostic core
# managers: copy (copyroom — templating / convergence) and git (gitman — version
# control). Language add-ons (e.g. template-py) extend repoman.managers with
# their own managers (test, …).
{ ... }:

{
  repoman.enable = true;
  repoman.cliProvider = "venv";
  repoman.managers = [ "copy" "git" ];
  vendor.toolchain.enable = false;

  # Python venv for uv-managed deps. The manager CLIs (copyroom, gitman) come from
  # the SYSTEM-WIDE toolchain venv (`repoman-sync --machine`), not this repo's venv.
  languages.python = {
    enable = true;
    venv.enable = true;
    uv.enable = true;
  };

  # devman — the automation plane (CONCEPT.md §5), with the direct task shape
  # (like nix-desktop): this repository has no Python suite, so the gate is the
  # flake. `--no-build` type-checks every option without realising a derivation
  # (the fast one); dropping the flag is the gate.
  devman = {
    enable = true;
    project = "nix-nvim";
    groups = [ "base" ];
  };

  # https://devenv.sh/tasks/
  tasks = {
    "base:check".exec = "nix flake check --no-build";
    "base:test".exec = "nix flake check";
  };
}
