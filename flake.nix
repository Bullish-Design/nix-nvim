# flake.nix — nix-nvim
#
# Rendered by the `module` layer of template-nix. The SKELETON (the inputs scaffold + the outputs
# structure) is template-owned; the
# `description`, the inter-library `inputs`, and the exported module attr list
# are THIS repo's to fill. A library that depends on another library adds that
# `path:` input itself — the template does not predict the DAG.
{
  description = "Home Manager module flake packaging the loci-rich Neovim config (nvim + keymaps + LSP client); consumed by nix-terminal, supersedes nixvim.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Inter-library inputs go here, added BY THIS LIBRARY when it depends on
    # another (path: in dev, github:…?ref=vX.Y.Z for the published fleet), each
    # carrying `inputs.nixpkgs.follows = "nixpkgs"` so the fleet collapses onto
    # one nixpkgs at nix-meta eval time.
  };

  outputs = { self, nixpkgs, ... }: {
    nixosModules = {
      # One attr per exported module file; `default` aggregates the rest (each
      # still behind its own enable flag). Add an attr per new modules/<name>.nix.
      example = import ./modules/example.nix;
      default = import ./modules/default.nix;
    };
  };
}
