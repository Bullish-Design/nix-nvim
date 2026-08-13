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
`treesitter.enable`, `clipboard` (osc52 | auto), `extraLuaConfig`. options.nix
declares, config.nix
implements behind `mkIf cfg.enable`.

The `config` body builds a `writeShellScriptBin` wrapper that launches the
pinned neovim with the shipped lua tree (`./runtime`, de-hardcoded — NOT
`~/.dotfiles/nvim`) on the runtimepath, the loci.nvim plugin appended to rtp,
treesitter grammars + `after/` on rtp, and the 9 ambient LSP servers +
`editorTools` (w3m, for zeal.nvim) + `loci-lsp` on PATH.

`lspServers` in config.nix MUST stay in step with `server_cmds` in
`runtime/lua/intelligence/lsp.lua`. The lua side gates `vim.lsp.enable` on
`executable()`, so a server shipped in nix but absent there is closure weight
that never runs.

## What lives here vs. loci.nvim

- **Here:** neovim 0.12 packaging, the non-loci lua tree (incl. the loci leader
  maps in `runtime/lua/keymaps/leader.lua` and the `require("loci")` call in
  `runtime/init.lua`), the vim.pack set, 9 LSP servers, and treesitter grammars.
- **Not here:** `lua/loci/` (the thin client) and `loci-lsp` — both come from the
  `loci-nvim` flake input (plugin → rtp, server → PATH).
- **Notes are loci's, end to end.** loci owns daily, scratch, note, search,
  backlinks, neighbors, and traversal. Do NOT add a second notes stack. The
  obsidian.nvim + tasknotes.nvim + bases.nvim + custom-notes layer that used to
  live here wrote to `~/Documents/Notes` while obsidian.nvim read
  `$LOCI_OBSIDIAN_VAULT` (`~/Notes`); the two never converged, and the vault
  path guards silently never matched.

## One way to do things

The house rules that keep the keymap surface single-valued:

- **Motion lives on the `[`/`]` and `g` grammars; `<leader>` holds lists and
  actions.** Do not mirror a motion onto `<leader>` — that is how
  `<leader>gn`/`gp`, `<leader>xn`/`xp` and `<leader>gr` came to shadow the
  mini.diff / mini.bracketed originals.
- **`gh`/`gH` belong to mini.diff** (apply hunk, reset hunk, hunk textobject).
  Treewalker is on `<M-hjkl>` / `<M-S-hjkl>`.
- **`<localleader>p` is Peek definition** from the LSP layer. `LspAttach` and
  `FileType` do not fire in a fixed order, so a ftplugin that also wants `p`
  produces a nondeterministic winner. Pick another letter.
- **Neovim's built-in `gr*` LSP defaults are deleted** in `keymaps/lsp.lua`.
  The `gd`/`gr`/`gI`/`gy` + `<localleader>` set is the single interface.
- **which-key `add()` only queues.** The queue drains on `VimEnter` via
  `vim.schedule`, so `keymaps/*.lua` always lands after every plugin `setup()`.
  Require order in `init.lua` does not decide these contests.

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
