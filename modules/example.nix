# modules/example.nix — the ONE authoring shape for the whole stack:
# namespaced options + a single `config = lib.mkIf cfg.enable { … }`.
# NEVER write an unconditional top-level `config` / bare attrs block.
#
# The frame below is template-owned (converges via `copyroom update`); the
# `config` body + any extra `options` are THIS repo's to fill.
{ config, lib, pkgs, ... }:
let
  cfg = config.nix-nvim.example;
in
{
  options.nix-nvim.example = {
    enable = lib.mkEnableOption "Home Manager module flake packaging the loci-rich Neovim config (nvim + keymaps + LSP client); consumed by nix-terminal, supersedes nixvim.";
    # Additional options for this concern go here, e.g.:
    # package = lib.mkPackageOption pkgs "<tool>" { };
  };

  config = lib.mkIf cfg.enable {
    # Concern implementation. Hardcode `andrew` where a username is needed;
    # NO multi-user / portability abstraction (personal-use-only).
  };
}
