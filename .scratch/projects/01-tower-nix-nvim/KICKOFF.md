# KICKOFF — implement `nix-nvim`: extract `.dotfiles/nvim` into a Home Manager module flake

You are starting a FRESH session. This repo (`~/Documents/Projects/nix-nvim`) is a
**scaffold** — `git init`'d, with a stub Neovim module and docs, but no real config
ported yet. Your job is to fill it in: turn the stub into a working Home Manager
module that reproduces the loci-rich Neovim at `~/.dotfiles/nvim`, then point
`nix-terminal` at it and retire `nixvim`.

Slug: `tower-nix-nvim`.

────────────────────────────────────────────────────────────────────────

## 0. Role in the larger project

This repo is the deliverable of **Phase 1** of the Tower Dotfiles project.

- **Master plan (source of truth, read first):**
  `/home/andrew/.dotfiles/.scratch/projects/37-tower-dotfiles/PLAN.md`
  — read §3 (canonical-nvim decision), §4 (architecture + repo map), §5 (pins),
  Phase 1 in §8, and §10 (open items).
- **Decision log:**
  `/home/andrew/.claude/projects/-home-andrew--dotfiles/memory/tower-dotfiles-project.md`
- **Maps to PLAN.md Phase 1:** *"Extract `.dotfiles/nvim` → `nix-nvim`; point
  `nix-terminal` at it; retire `nixvim`."*

Position in the stack:

```
nix-terminal    HM terminal env   shell · atuin · tmux · zellij · → nix-nvim   ← consumes this
nix-nvim        HM nvim (loci)    promoted from .dotfiles/nvim                  ← THIS REPO
```

`nix-nvim` **supersedes** `Bullish-Design/nixvim` — that flake is retired once
this reaches parity.

## 1. Acceptance criteria (done when…)

- `nix flake check` passes.
- A consumer home config that does
  `imports = [ nix-nvim.homeManagerModules.neovim ]; programs.nix-nvim.enable = true;`
  installs a Neovim launcher that comes up with **loci + keymaps + treesitter +
  LSP at parity with `~/.dotfiles/nvim`** — i.e. the same experience the laptop
  gets today from `nv`.
- `nix-terminal` imports `nix-nvim.homeManagerModules.neovim` (or `.default`)
  **instead of** its `nixvim` input, and a home build still produces a working
  `nvim`/`nv`.
- The loci LSP client attaches (requires `loci-lsp` on PATH — see §4).
- Treesitter highlighting works (grammars bundled, not fetched at runtime).

## 2. Current scaffold (what already exists here)

```
flake.nix                              homeManagerModules.neovim → ./modules/neovim (+ .default alias)
modules/neovim/default.nix             imports options + config
modules/neovim/options.nix             STUB: declares programs.nix-nvim.* (bodies = TODO)
modules/neovim/config.nix              STUB: mkIf cfg.enable { } (bodies = TODO)
README.md / AGENTS.md / .gitignore
```

The flake exports both `homeManagerModules.neovim` and `homeManagerModules.default`
(alias) so the nix-terminal swap is a one-line input change.

## 3. Work items (target paths in THIS repo)

1. **`flake.nix`** — add real inputs. The source config pins **neovim 0.12** and a
   large plugin set via the `.dotfiles` flake; decide how to carry those (explicit
   input/overlay vs vendor) so they don't regress (PLAN.md §5 / §10). Uncomment /
   wire any nvim-dep inputs (e.g. a neovim overlay; optionally a `loci-core` input
   for `loci-lsp`).
2. **`modules/neovim/options.nix`** — flesh out `programs.nix-nvim.*`:
   - `enable` (already stubbed)
   - launcher command name (`default = "nvim"`; laptop aliases it to `nv`)
   - `extraPackages` (LSP servers / tools on Neovim's PATH)
   - loci toggle (+ whether to ensure `loci-lsp` on PATH)
   - treesitter grammar wiring toggle
3. **`modules/neovim/config.nix`** — implement under `mkIf cfg.enable`:
   - the launcher wrapper (see §4 for the exact source pattern)
   - place the lua config tree into Neovim's runtimepath (decide: ship as a
     derivation / `home.file` instead of the source's `~/.dotfiles/nvim` hard path)
   - install LSP servers + the loci client; ensure `loci-lsp` reachable.
4. **`nix-terminal` (separate repo, `~/Documents/Projects/nix-terminal`)** —
   the integration edit (see §5). Do this only after the module builds standalone.

## 4. Source material to port FROM (all under `~/.dotfiles/nvim`, READ-ONLY)

Do **not** modify `~/.dotfiles`. Copy/port out of it.

| Source path | What it is | Port note |
|---|---|---|
| `default.nix` | The Nix wrapper. `writeShellScriptBin "nvim"` that execs `${neovim}/bin/nvim -u init.lua`, prepends `${srcDir}` + `${srcDir}/after` + a treesitter grammar `symlinkJoin` to rtp, and exports `LD_LIBRARY_PATH` for sqlite. Also lists the LSP servers (`basedpyright ty ruff vtsls vscode-langservers-extracted lua-language-server nil rust-analyzer yaml-language-server markdown-oxide`). | This is the model for `config.nix`. **Key change:** `srcDir` currently hard-codes `${config.home.homeDirectory}/.dotfiles/nvim`; in this repo the lua tree must travel WITH the module, not point back at `.dotfiles`. |
| `init.lua` | Bootstrap. Sets leaders, declares ~50 plugins via native **`vim.pack`**, then `require`s every module incl. `require("loci")` (the thin client self-inits, no `setup()`). | Ship verbatim into the runtimepath. Note `vim.pack` fetches plugins from GitHub at runtime today — decide whether to keep that or pin/vendor plugins via nix (parity-relevant; PLAN.md §10). |
| `lua/loci/init.lua` | **The loci client** — a single ~31KB file. It is now a *thin LSP client* (see decision log `[[loci-swap-clean-room]]`): it attaches a `pygls` server and translates editor events; it holds no loci logic. | **Hard dependency:** needs the **`loci-lsp`** console script on PATH (installed via uv tool from `loci-core/lsp`, or packaged). If `loci-lsp` is not on Neovim's PATH the attach silently fails — call this out in options/config and document in README. |
| `lua/keymaps/leader.lua` | The `<leader>l` Loci keymap tree (`<leader>lp` palette, `ls` status, `lw` workspaces, `lP` projects, `ld` doctor, `lnd/lns/lnn` notes) plus the rest of the leader map (48 commands). | Port as-is. |
| `lua/keymaps/{global,navigation,lsp}.lua` | Rest of keymaps. | Port as-is. |
| `lua/intelligence/` | LSP setup (`lsp.lua` — per-language root/python detection), `completion.lua` (blink.cmp), `treesitter.lua`, plus wtf/overlook/outline/allium/luasnip. | Port as-is. `lsp.lua` references the server binaries listed in `default.nix`. |
| `lua/{core,ui,editing,visual,interaction,git,workspace,sidequest,development,productivity,project,config}/` | The rest of the config. | Port the whole tree. |
| `after/ftplugin/*.lua` | Per-filetype settings (json/lua/markdown/nix/python/toml/yaml). | Must stay in rtp's `after/`. |
| `docs/` | Plugin/feature docs incl. `docs/loci/` (state-ownership, workspace-lifecycle, troubleshooting…). | Optional to ship; useful as in-repo reference. |
| treesitter grammars | `pkgs.vimPlugins.nvim-treesitter.withAllGrammars.dependencies` → `symlinkJoin` → prepended to rtp (in `default.nix`). | Reproduce; grammars must be bundled at build time, not compiled at runtime. |
| `nv` wrapper | The launcher is named `nvim` here but the laptop aliases/invokes it as `nv`. | Preserve the wrapper; the alias is a consumer concern (nix-terminal). |
| `neoconf.json`, `.nvimlog`/`nvim.log` | neoconf config; logs. | Port `neoconf.json`; ignore the logs. |

**loci-lsp source:** `~/Documents/Projects/loci-core/lsp` (pyproject defines the
`loci-lsp` console script). Install pattern today:
`uv tool install --from /home/andrew/Documents/Projects/loci-core/lsp loci-lsp`.
Decide whether `nix-nvim` packages it (a `loci-core` flake input) or leaves it to
the consumer/`nix-secrets`-adjacent tooling — but the dependency MUST be documented.

## 5. Integration / dependencies

### Consumed by nix-terminal (do this edit there, after the module builds)

`~/Documents/Projects/nix-terminal/flake.nix` currently has:

```nix
nixvim = { url = "github:Bullish-Design/nixvim/main"; inputs.nixpkgs.follows = "nixpkgs"; };
...
homeManagerModules.terminal = import ./modules/terminal.nix { inherit nixvim devman; };
```

and `~/Documents/Projects/nix-terminal/modules/terminal.nix` imports
`nixvim.homeManagerModules.default`.

**The swap:**
- Replace the `nixvim` input with `nix-nvim = { url = "github:Bullish-Design/nix-nvim"; inputs.nixpkgs.follows = "nixpkgs"; };`
- Thread `nix-nvim` into `terminal.nix` and change the import to
  `nix-nvim.homeManagerModules.neovim` (or `.default`).
- Update `nix-terminal`'s README/AGENTS dependency table (it still names `nixvim`).

### Retire nixvim

Once `nix-terminal` builds against `nix-nvim` at parity, **`Bullish-Design/nixvim`
is retired** (archive / mark superseded). Do not delete until parity is confirmed
in a real home build.

## 6. Repo-relevant open items (from PLAN.md §5 / §10)

- **Carry the `.dotfiles` nixpkgs pins** — neovim 0.12 specifically, plus the
  plugin/grammar set — or the config regresses (§5). Decide pin strategy in §3.1.
- **Treesitter grammars** — bundle at build time (§10 touches headless/runtime
  concerns; here the concern is reproducibility).
- **vim.pack vs nix-pinned plugins** — the source fetches plugins from GitHub at
  runtime via `vim.pack`. Decide whether that stays (simplest, less hermetic) or
  plugins get vendored/pinned through nix (more reproducible). Not blocking for a
  first parity pass, but note the choice.

## 7. Guardrails

- Write only inside `~/Documents/Projects/nix-nvim` (and, for the integration step,
  the explicit edits in `~/Documents/Projects/nix-terminal`). **Never modify
  `~/.dotfiles`** — it is the read-only extraction source and the laptop keeps
  booting from it until cutover.
- Don't add Co-Authored-By / "Generated with" / any AI-authorship trailer anywhere.
- Keep the `programs.nix-nvim.*` namespace (mirrors `programs.nix-terminal.*`).
- Validate in a real consumer home build, not just `nix flake check`, before
  declaring parity or retiring `nixvim`.
