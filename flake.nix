# flake.nix — nix-nvim
#
# Rendered from template-nix. The SKELETON (the inputs scaffold + the outputs
# structure) is template-owned and re-converges via `copyroom update`; the
# `description`, the inter-library `inputs`, and the exported module attr list
# are THIS repo's to fill. A library that depends on another library adds that
# `path:` input itself — the template does not predict the DAG.
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
    # plugin → rtp, loci-lsp → PATH, loci CLI → profile. Published pin (pure
    # eval; loci.nvim@v0.1.2 fetched loci-core + its knappy dep over git+ssh so
    # the loci stack resolves on headless boxes — v0.1.1's github: pin 404'd on
    # the private loci-core). v0.1.4 added the packages.loci re-export; v0.2.0
    # realigns the client with the V2 engine wire contract (loci/<wire>
    # features, previews, pull diagnostics, saveResult; the engine's pygls
    # host + `loci init` landed on loci-core main @4a8d5e2). v0.2.1 carries
    # loci-core @81d38ba, which aliases packages.loci-lsp onto the loci-core
    # derivation instead of building the same source twice — that duplicate was
    # what made buildEnv abort on the shared bin/.loci-wrapped and fail every
    # rebuild — and completes the V2 plugin surface.
    #
    # v0.3.0 carries loci-core @c34dc83 (v0.4.1), which fixes `:w` on a NEW note.
    # Every save of a note created during the session was refused forever
    # (`destination_exists`) and — worse than the warning — never indexed it, so
    # the note stayed invisible to search and the graph. Minor, not patch: that is
    # the first thing a user does with the editor. loci.nvim t34 measures the fix
    # against the real server and fails against the previous engine build.
    loci-nvim = {
      url = "github:Bullish-Design/loci.nvim?ref=v0.3.0";
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
