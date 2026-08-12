# modules/default.nix — aggregate; imports every sibling module. Each module
# stays behind its own enable flag, so importing `default` is inert until one is
# switched on. Multi-module libraries extend this import list (one entry per
# modules/<name>.nix). nix-meta imports the modules discretely and never relies
# on this aggregate; it exists for template convergence + flake-show completeness.
{ imports = [ ./example.nix ]; }
