# Option surface for nix-nvim.neovim (nix-nvim-PLAN §3.2).
# Namespace is the stack-wide repo-root convention `nix-nvim.neovim.*`
# (AMENDS the scaffold's `programs.nix-nvim.*`).
{ inputs }:
{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
  # The neovim 0.12 pin (d2339023 → 0.12.2), imported for the `package` default.
  # This is the only deliberate second-nixpkgs node nix-nvim owns (does NOT
  # follow the unstable root — it must stay at 0.12.x for vim.pack).
  pkgsNeovim = import inputs.nixpkgs-neovim { inherit (pkgs) system; };
in
{
  options.nix-nvim.neovim = {
    enable = mkEnableOption "the loci-rich Neovim 0.12 launcher + its lua tree, LSP servers, grammars, and loci";

    command = mkOption {
      type = types.str;
      default = "nvim";
      description = "Name of the wrapper bin. nix-terminal sets this to `nv`.";
    };

    package = mkOption {
      type = types.package;
      default = pkgsNeovim.neovim;
      defaultText = lib.literalExpression "nixpkgs-neovim (d2339023).neovim  # 0.12.2";
      description = ''
        The neovim to wrap. Defaulted from the `nixpkgs-neovim` pin (0.12.2).
        Overridable but MUST be >=0.12 (the lua config uses `vim.pack`).
      '';
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = ''
        Extra tools/LSP servers to add to the launcher's PATH (beyond the
        bundled ambient set). Project-scoped servers/toolchains belong in
        devenv-lib, not here (nix-nvim-PLAN §7).
      '';
    };

    loci.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Place the loci.nvim plugin on the runtimepath and `loci-lsp` on PATH.
        Off → a loci-less editor (the lua `require("loci")` self-guards; the
        client already warns-once then no-ops when `loci-lsp` is absent).
      '';
    };

    treesitter.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Bundle `nvim-treesitter.withAllGrammars` grammars (symlinkJoin → rtp)
        at build time. Off → rely on runtime grammar compilation (loses
        reproducibility; not recommended).
      '';
    };

    clipboard = mkOption {
      type = types.enum [ "auto" "osc52" ];
      default = "auto";
      description = ''
        Clipboard provider strategy:

        - `auto` (default): use the local graphical provider when one is
          available in the current session (wl-clipboard on a Wayland desktop,
          xclip/xsel on X11, pbcopy on macOS, …), otherwise fall back to the
          built-in OSC 52 provider. This is the portable policy: a desktop
          session gets direct clipboard access, while an SSH/TUI session into a
          headless box has no local provider, so copy/paste travels as an escape
          sequence to the client terminal (kitty, alacritty, wezterm, iTerm2,
          Windows Terminal, …) — no "No provider available" warning.
        - `osc52`: force the built-in OSC 52 provider and skip the
          local-provider check. Use only if you must reach the client
          terminal's clipboard from a host that does have a local provider.
      '';
    };

    # `obsidian.vaultPath` is gone. It exported LOCI_OBSIDIAN_VAULT, which only
    # obsidian.nvim ever read — neither loci.nvim nor loci-core reference it.
    # The runtime now has one notes system (loci), which locates its own vault,
    # so the option had no consumer left. nix-terminal never set it.

    extraLuaConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Optional extra lua appended after the shipped init.lua (escape hatch).";
    };
  };
}
