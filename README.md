# nix-nvim

Home Manager module flake packaging the loci-rich Neovim config (nvim + keymaps + LSP client); consumed by nix-terminal, supersedes nixvim.

A [devenv](https://devenv.sh) project. Copyroom handles templating and
convergence. Gitman and jj handle version control.

## Getting started

```bash
devenv shell          # enter the pinned environment
copyroom status       # check the template state
```

## Staying current with the template

This project uses local Templateer sources from `template-nix`. Update its base
layer to a released ref:

```bash
copyroom update --ref <template-ref>
```

Projects with the `module` layer must update that layer too:

```bash
copyroom update --layer module --ref <template-ref>
```

## Author

Bullish Design <BullishDesignEngineering@gmail.com>
