# AGENTS.md

## Repository Overview

**nix-nvim** is a Home Manager module flake that packages the loci-rich Neovim
configuration promoted from `~/.dotfiles/nvim`. It is consumed by **nix-terminal**
(replacing its old `nixvim` input) and **supersedes** `Bullish-Design/nixvim`.

This repo is also a [repoman](https://github.com/Bullish-Design/repoman)-managed
devenv project (see `devenv.nix`, `repoman.lock`) — the toolchain/version-control
layer is orthogonal to the Nix module layer below.

## Architecture

```
flake.nix  (inputs: nixpkgs · nixpkgs-neovim d2339023 · home-manager · loci-nvim)
    └── homeManagerModules.{neovim, default}  → modules/neovim/
            ├── default.nix  ({ inputs }: imports options + config, curried)
            ├── options.nix   (nix-nvim.neovim.*)
            ├── config.nix    (mkIf cfg.enable → the `nv` wrapper)
            └── runtime/      (the shipped lua tree: init.lua + lua/* minus
                               lua/loci/ + after/ + neoconf.json)
```

Options live under **`nix-nvim.neovim.*`** (repo-root convention, AMENDS the old
`programs.nix-nvim.*`): `enable`, `command` (consumer sets `nv`), `package`
(defaults to the neovim 0.12.2 pin), `extraPackages`, `loci.enable`,
`treesitter.enable`, `extraLuaConfig`. options.nix declares, config.nix
implements behind `mkIf cfg.enable`.

The `config` body builds a `writeShellScriptBin` wrapper that launches the
pinned neovim with the shipped lua tree (`./runtime`, de-hardcoded — NOT
`~/.dotfiles/nvim`) on the runtimepath, the loci.nvim plugin appended to rtp,
treesitter grammars + `after/` on rtp, and the 9 ambient LSP servers + `loci-lsp`
on PATH.

## What lives here vs. loci.nvim

- **Here:** neovim 0.12 packaging, the non-loci lua tree (incl. the loci leader
  maps in `runtime/lua/keymaps/leader.lua` and the `require("loci")` call in
  `runtime/init.lua`), the vim.pack set, 9 LSP servers, treesitter grammars, and
  **tasknotes** (the `tasknotes.nvim` plugin rides vim.pack; setup is in the
  productivity lua tree).
- **Not here:** `lua/loci/` (the thin client) and `loci-lsp` — both come from the
  `loci-nvim` flake input (plugin → rtp, server → PATH).

## Status

Built + validated (Wave 2): `nix flake check` green; the wrapped neovim builds in
a real HM eval; loci plugin proven on rtp and `loci-lsp` on PATH; single-nixpkgs
audit clean (`nixpkgs-neovim` is the only sanctioned extra node).

## Integration Points

- **Consumed by** `nix-terminal` (`homeManagerModules.neovim` / `.default`).
- **Consumes** `loci-nvim.packages.<sys>.{loci-nvim, loci-lsp}` (`path:` input in
  dev; `repoman fleet flake-update` swaps to a tagged `github:` at publish).
- **Supersedes** `Bullish-Design/nixvim` (retire after cutover).

## Project

Part of the **Tower Dotfiles** project — master plan at
`~/.dotfiles/.scratch/projects/37-tower-dotfiles/PLAN.md` (Phase 1).
