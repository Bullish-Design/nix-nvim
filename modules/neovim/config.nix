# config body for nix-nvim.neovim — the `nv` launcher wrapper.
# Modeled on ~/.dotfiles/nvim/default.nix, de-hardcoded: the lua tree travels
# WITH the module as a nix store path (./runtime), NOT ~/.dotfiles/nvim.
{ inputs }:
{ config, lib, pkgs, ... }:
let
  # `escapeShellArg` is gone with the LOCI_OBSIDIAN_VAULT export — nothing else
  # in this file needs shell quoting.
  inherit (lib) mkIf optional optionalString concatStringsSep makeBinPath;
  cfg = config.nix-nvim.neovim;

  # The loci editor stack from the loci.nvim flake (nix-nvim-PLAN §3.3/§6):
  #   plugin → runtimepath ; loci engine (loci + loci-lsp) → launcher PATH + profile.
  lociPlugin = inputs.loci-nvim.packages.${pkgs.system}.loci-nvim;

  # loci.nvim re-exports loci-core's engine under two attribute names —
  # `loci` (the CLI: the vault BOOTSTRAP path `loci repository.init`, since the
  # client cannot attach until a `.loci/` exists, plus the out-of-editor arm)
  # and `loci-lsp` (the LSP host the launcher needs on PATH). Upstream builds
  # them from one wheel whose [project.scripts] ships BOTH consoles, so a single
  # package provides `loci` and `loci-lsp` together.
  #
  # Take it once. Referencing both attrs installed the same engine twice, and
  # buildEnv aborts on the shared `bin/.loci-wrapped`, failing the entire
  # home-manager generation. loci-core now aliases the two names onto one
  # derivation so that is structurally impossible; taking one attr is correct
  # either way, including against an older lock where they were separate builds.
  lociEngine = inputs.loci-nvim.packages.${pkgs.system}.loci;

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
  #
  # This list must stay in step with `server_cmds` in
  # runtime/lua/intelligence/lsp.lua: the lua side gates `vim.lsp.enable` on
  # `executable()`, so a server shipped here but not configured there is closure
  # weight that never runs. basedpyright was exactly that — shipped, never
  # enabled, and a second Python checker next to `ty` if it ever had been.
  lspServers = with pkgs; [
    ty # python types
    ruff # python lint/format
    vtsls
    vscode-langservers-extracted # html, json (css + eslint ride along unused)
    lua-language-server
    nil # nix
    rust-analyzer
    yaml-language-server
    markdown-oxide
  ];

  # Non-LSP tools the runtime shells out to. zeal.nvim drives a terminal browser
  # (`browser = { "w3m", ... }`); without w3m on PATH, <leader>fz and the whole
  # w3m keymap layer in runtime/lua/development/zeal.lua cannot work.
  editorTools = with pkgs; [ w3m ];

  # Everything the launcher needs on PATH (so vim.fn.executable("loci-lsp") and
  # the ambient servers resolve regardless of the surrounding shell env).
  pathPkgs = lspServers ++ editorTools ++ cfg.extraPackages
    ++ optional cfg.loci.enable lociEngine;

  extraLuaFile = pkgs.writeText "nix-nvim-extra.lua" cfg.extraLuaConfig;

  # `--cmd` flags run before init.lua (rtp prepends); `-c` runs after startup.
  cmdFlags = concatStringsSep " " (
    [
      ''--cmd "set rtp^=${srcDir}"''
      ''--cmd "set rtp+=${srcDir}/after"''
      ''--cmd "let g:nix_nvim_clipboard = '${cfg.clipboard}'"''
    ]
    ++ optional cfg.treesitter.enable ''--cmd "set rtp^=${grammarPath}"''
    ++ optional cfg.loci.enable ''--cmd "set rtp+=${lociPlugin}"''
  );
  postFlags = optionalString (cfg.extraLuaConfig != "") ''-c "luafile ${extraLuaFile}"'';

  wrapper = pkgs.writeShellScriptBin cfg.command ''
    # sqlite carried from the source wrapper (defensive; audit candidate — §10 Q4).
    export LD_LIBRARY_PATH="${pkgs.sqlite.out}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export PATH="${makeBinPath pathPkgs}''${PATH:+:$PATH}"
    exec ${cfg.package}/bin/nvim -u "${srcDir}/init.lua" ${cmdFlags} ${postFlags} "$@"
  '';
in
{
  config = mkIf cfg.enable {
    home.packages = [ wrapper ] ++ lspServers ++ editorTools ++ cfg.extraPackages
      ++ optional cfg.loci.enable lociEngine;
  };
}
