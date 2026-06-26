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
flake.nix
    └── homeManagerModules.neovim  (+ .default alias) → modules/neovim/
                                         ├── default.nix  (imports)
                                         ├── options.nix  (programs.nix-nvim.*)
                                         └── config.nix   (mkIf cfg.enable …)
```

Options live under `programs.nix-nvim.*`, following the nix-terminal module
pattern (options.nix declares, config.nix implements behind `mkIf cfg.enable`).

## Status

Scaffold only. The implementation slice (porting the nvim config to parity) is
specified in `.scratch/projects/01-tower-nix-nvim/KICKOFF.md`. Do **not** port
nvim logic until working that packet.

## Integration Points

- **Consumed by** `nix-terminal` (`homeManagerModules.neovim` / `.default`).
- **Depends on** the `loci-lsp` server being on PATH (loci is now a thin LSP
  client — see the kickoff packet).
- **Supersedes** `Bullish-Design/nixvim` (retire after cutover).

## Project

Part of the **Tower Dotfiles** project — master plan at
`~/.dotfiles/.scratch/projects/37-tower-dotfiles/PLAN.md` (Phase 1).
