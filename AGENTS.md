# AGENTS.md — nix-nvim

Home Manager module flake packaging the loci-rich Neovim config (nvim + keymaps + LSP client); consumed by nix-terminal, supersedes nixvim.

## What this repo is
A `template-nix`-derived **nixos module library** in the tower-dotfiles
fleet. It exports option-gated NixOS
modules; **composition lives ONLY in `nix-meta`** — this repo never declares
nixosConfigurations,
hosts, or `mkHost`.

## Conventions (inherited from template-nix — do not break)
- Every module: `options.nix-nvim.<module>.enable` + a single
  `config = lib.mkIf cfg.enable { … }`. **No unconditional config.**
- One file per concern under `modules/`; `modules/default.nix` aggregates them.
- The flake exports exactly `nixosModules`
  (+ a `default` aggregate). No composition outputs.
- Personal-use-only: hardcode `andrew`; no portability / multi-user ceremony.
- In-repo ops go through the devenv: `devenv shell -- <cmd>`.

## Inherited vs owned
- **Inherited** (converged by CopyRoom): `devenv.{nix,yaml}`, `repoman.lock`,
  `.gitignore`, and the module *frame*.
- **Owned** (template seeds, you fill): flake `description`/`inputs`/outputs-attrs,
  module `config` bodies + extra options, `modules/default.nix` import list, docs, optional `scripts/`.

## Validate
`nix flake check` (+ `nix flake show` to confirm the exported module set).

## Author
Bullish Design <BullishDesignEngineering@gmail.com>
