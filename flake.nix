{
  description = "Home Manager module flake packaging the loci-rich Neovim 0.12 config (promoted from .dotfiles/nvim); consumes loci.nvim, supersedes nixvim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # ── neovim 0.12 pin (OWNED HERE — nix-nvim-PLAN §5) ──────────────────
    # The vim.pack-capable neovim. A second nixpkgs input that must NOT follow
    # the unstable root (it stays at d2339023 → neovim 0.12.2). The module
    # imports this for its `package` default (mirrors the .dotfiles overlay).
    nixpkgs-neovim.url = "github:NixOS/nixpkgs/d2339023";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── the loci editor stack (CONSUMED — nix-nvim-PLAN §6) ──────────────
    # plugin → rtp, loci-lsp → PATH. Published pin (pure eval; loci.nvim@v0.1.1
    # carries the activation fix and pins loci-core@02be76d / pygls 2.1.1).
    loci-nvim = {
      url = "github:Bullish-Design/loci.nvim?ref=v0.1.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    homeManagerModules = rec {
      # nix-nvim's own resolved inputs (the 0.12 pin + loci.nvim) are baked in
      # here so the consumer (nix-terminal/nix-meta) only does `imports = [ … ]`.
      neovim = import ./modules/neovim { inherit inputs; };
      default = neovim; # alias — one-line nixvim → nix-nvim swap in nix-terminal
    };
  };
}
