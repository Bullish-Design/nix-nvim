# config body for nix-nvim.neovim — the `nv` launcher wrapper.
# Modeled on ~/.dotfiles/nvim/default.nix, de-hardcoded: the lua tree travels
# WITH the module as a nix store path (./runtime), NOT ~/.dotfiles/nvim.
{ inputs }:
{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf optional optionalString concatStringsSep makeBinPath escapeShellArg;
  cfg = config.nix-nvim.neovim;

  # The loci editor stack from the loci.nvim flake (nix-nvim-PLAN §3.3/§6):
  #   plugin → runtimepath ; loci-lsp binary → launcher PATH.
  lociPlugin = inputs.loci-nvim.packages.${pkgs.system}.loci-nvim;
  lociLsp = inputs.loci-nvim.packages.${pkgs.system}.loci-lsp;

  # The shipped lua tree (init.lua + lua/* minus lua/loci/ + after/ + neoconf.json)
  # as a store path. This is the central de-hardcode of srcDir.
  srcDir = ./runtime;

  # Treesitter grammars bundled at build time (verbatim from source default.nix).
  grammarPath = pkgs.symlinkJoin {
    name = "nvim-treesitter-grammars";
    paths = pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies;
  };

  # The ambient editor LSP servers (nix-nvim-PLAN §1/§7) — always-on, attach in
  # any buffer. Project toolchains are devenv-lib's, not here. All ride nixpkgs.
  lspServers = with pkgs; [
    basedpyright
    ty
    ruff
    vtsls
    vscode-langservers-extracted # html, json, css, eslint
    lua-language-server
    nil # nix
    rust-analyzer
    yaml-language-server
    markdown-oxide
  ];

  # Everything the launcher needs on PATH (so vim.fn.executable("loci-lsp") and
  # the ambient servers resolve regardless of the surrounding shell env).
  pathPkgs = lspServers ++ cfg.extraPackages ++ optional cfg.loci.enable lociLsp;

  extraLuaFile = pkgs.writeText "nix-nvim-extra.lua" cfg.extraLuaConfig;

  # `--cmd` flags run before init.lua (rtp prepends); `-c` runs after startup.
  cmdFlags = concatStringsSep " " (
    [
      ''--cmd "set rtp^=${srcDir}"''
      ''--cmd "set rtp+=${srcDir}/after"''
    ]
    ++ optional cfg.treesitter.enable ''--cmd "set rtp^=${grammarPath}"''
    ++ optional cfg.loci.enable ''--cmd "set rtp+=${lociPlugin}"''
  );
  postFlags = optionalString (cfg.extraLuaConfig != "") ''-c "luafile ${extraLuaFile}"'';

  wrapper = pkgs.writeShellScriptBin cfg.command ''
    # sqlite carried from the source wrapper (defensive; audit candidate — §10 Q4).
    export LD_LIBRARY_PATH="${pkgs.sqlite.out}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export PATH="${makeBinPath pathPkgs}''${PATH:+:$PATH}"
    export LOCI_OBSIDIAN_VAULT=${escapeShellArg cfg.obsidian.vaultPath}
    exec ${cfg.package}/bin/nvim -u "${srcDir}/init.lua" ${cmdFlags} ${postFlags} "$@"
  '';
in
{
  config = mkIf cfg.enable {
    home.packages = [ wrapper ] ++ lspServers ++ cfg.extraPackages
      ++ optional cfg.loci.enable lociLsp;
  };
}
