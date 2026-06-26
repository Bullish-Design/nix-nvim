# nix-nvim.neovim — the editor module.
# Curried with nix-nvim's own resolved inputs (the neovim 0.12 pin + loci.nvim)
# so the consumer only does `imports = [ nix-nvim.homeManagerModules.neovim ]`.
{ inputs }:
{
  imports = [
    (import ./options.nix { inherit inputs; })
    (import ./config.nix { inherit inputs; })
  ];
}
