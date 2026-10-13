# nix-nvim — devenv for the Home Manager module flake and its flake gate.
#
# The host profile puts copyroom and gitman on PATH.
{ pkgs, ... }:

{
  # copyroom runs `git` and `patch` (gnupatch) as child processes.
  packages = [
    pkgs.git
    pkgs.gnupatch
  ];

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
