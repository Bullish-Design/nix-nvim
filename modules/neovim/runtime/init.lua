vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, { desc = "Update vim.pack plugins" })

vim.cmd([[
  cnoreabbrev <expr> packupdate ((getcmdtype() ==# ':' && getcmdline() ==# 'packupdate') ? 'PackUpdate' : 'packupdate')
]])

vim.pack.add({
  { src = "https://github.com/echasnovski/mini.nvim",                       version = "v0.17.0" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "851e865342e5a4cb1ae23d31caf6e991e1c99f1e" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context",     version = "v1.0.0" },
  { src = "https://github.com/Saghen/blink.cmp",                            version = "v1.10.2" },
  { src = "https://github.com/neovim/nvim-lspconfig",                       version = "v2.9.0" },
  -- friendly-snippets is read DIRECTLY by blink.cmp's built-in snippet source
  -- (snippets.preset = "default"). Do not add LuaSnip back: blink only calls
  -- LuaSnip when the preset is "luasnip", so it would parse the same set twice
  -- into a registry nothing reads.
  { src = "https://github.com/rafamadriz/friendly-snippets",                version = "6cd7280adead7f586db6fccbd15d2cac7e2188b9" },
  { src = "https://github.com/folke/snacks.nvim",                           version = "v2.31.0" },
  -- plenary + nui are TRANSITIVE deps, not direct: neogit / neotest /
  -- todo-comments / wtf need plenary; wtf needs nui. Keep both.
  { src = "https://github.com/rachartier/tiny-cmdline.nvim",                version = "ad58747b955d0743ccfd56e97da1a4c1fac89f58" },
  { src = "https://github.com/nanozuki/tabby.nvim",                         version = "v2.8.1" },
  { src = "https://github.com/folke/edgy.nvim",                             version = "v1.10.2" },
  { src = "https://github.com/NeogitOrg/neogit",                            version = "v3.0.0" },
  { src = "https://github.com/sindrets/diffview.nvim",                      version = "4516612fe98ff56ae0415a259ff6361a89419b0a" },
  { src = "https://github.com/gbprod/yanky.nvim",                           version = "v2.0.0" },
  { src = "https://github.com/MagicDuck/grug-far.nvim",                     version = "1.6.69" },
  { src = "https://github.com/stevearc/resession.nvim",                     version = "v1.2.0" },
  { src = "https://github.com/tris203/precognition.nvim",                   version = "v1.3.0" },
  { src = "https://github.com/folke/todo-comments.nvim",                    version = "v1.5.0" },
  { src = "https://github.com/nvim-lua/plenary.nvim",                       version = "v0.1.4" },
  { src = "https://github.com/rebelot/kanagawa.nvim",                       version = "master" },
  { src = "https://github.com/Bullish-Design/wayfinder.nvim",               version = "v0.3.0" },
  { src = "https://github.com/TheNoeTrevino/haunt.nvim",                    version = "v1.2.0" },
  { src = "https://github.com/paradoxical-dev/zeal.nvim",                   version = "5b60a017ccc0bd9e0f4768367e425fdae6a6e500" },
  { src = "https://github.com/MunifTanjim/nui.nvim",                        version = "0.4.0" },
  { src = "https://github.com/nvim-neotest/neotest",                        version = "v5.18.0" },
  { src = "https://github.com/piersolenski/wtf.nvim",                       version = "ef7c22daf5c99f4c96fc2d0719d6f1848802fc02" },
  { src = "https://github.com/m-demare/hlargs.nvim",                        version = "0b29317c944fb1f76503ce4540d6dceffbb5ccd2" },
  { src = "https://github.com/rachartier/tiny-code-action.nvim",            version = "0d040ed81f7953118b81cd12681fcdfcac069803" },
  { src = "https://github.com/WilliamHsieh/overlook.nvim",                  version = "6f74f20a61204275989050a2c1221bdc53b534c4" },
  { src = "https://github.com/nvim-neotest/nvim-nio",                       version = "v1.10.1" },
  { src = "https://github.com/nvim-neotest/neotest-python",                 version = "e6df4f1892f6137f58135917db24d1655937d831" },
  { src = "https://github.com/folke/which-key.nvim",                        version = "v3.17.0" },
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",   version = "v8.12.0" },
  { src = "https://github.com/delphinus/md-render.nvim",                    version = "v3.1.1" },
  { src = "https://github.com/hedyhli/outline.nvim",                        version = "v1.2.0" },
  { src = "https://github.com/swaits/zellij-nav.nvim",                      version = "91cc2a642d8927ebde50ced5bf71ba470a0fc116" },
  { src = "https://github.com/aaronik/treewalker.nvim",                     version = "0b081bf6c6875cf3e478b633796a9e2b64b730e8" },
  { src = "https://github.com/serhez/bento.nvim",                           version = "feat/v2" },
  { src = "https://github.com/folke/neoconf.nvim",                          version = "v1.4.0" },
  { src = "https://github.com/juxt/nvim-allium",                            version = "ae0bade344973347f695991f15dfe76ea0299253" },
})

require("core.options")
require("core.autocmds")
require("config.neoconf")

require("ui.colorscheme")
require("ui.misc")
require("ui.ui2")
require("ui.tiny_cmdline")
require("ui.statusline")
require("ui.tabline")
require("ui.bento")

require("editing.pairs")
require("editing.surround")
require("editing.ai")
require("editing.move")
require("editing.splitjoin")
require("editing.bracketed")
require("editing.yanky")
require("editing.grug_far")

require("visual.hipatterns")
require("visual.icons")
require("visual.todo_comments")
require("visual.precognition")
require("visual.scope")
require("visual.hlargs")

require("intelligence.treesitter")
require("intelligence.completion")
require("intelligence.lsp")
require("intelligence.wtf")
require("intelligence.tiny_code_action")
require("intelligence.overlook")
require("intelligence.allium")
require("intelligence.outline")

require("interaction.dashboard")
require("interaction.picker")
require("interaction.explorer")
require("interaction.scratch")
require("interaction.terminal")
require("interaction.zellij")
require("interaction.snacks")

require("git.signs")
require("git.commands")
require("git.neogit")
require("git.browse")

require("workspace.edgy")
require("workspace.sessions")
require("workspace.submodes")
require("sidequest").setup({
  trees = {
    workspace = require("sidequest.pages.workspace"),
    sessions = require("sidequest.pages.sessions"),
    git = require("sidequest.pages.git"),
  },
})

-- Development tools
require("development.wayfinder")
require("development.haunt")
require("development.zeal")
require("development.neotest")

-- Productivity. loci owns notes end-to-end: daily, scratch, note, search,
-- backlinks, neighbors, traversal. Do not add a second notes stack — the
-- obsidian.nvim / tasknotes / custom-notes layer that lived here wrote to a
-- different vault root than loci did, and the two never converged.
require("productivity.md_render")
require("loci")

require("keymaps.global")
require("keymaps.navigation")
require("keymaps.leader")
require("keymaps.lsp")

require("ui.which_key")
require("render-markdown").setup({
  latex = { enabled = false },
})

-- Use snacks notifier history as :messages
-- vim.cmd([[cnoreabbrev <expr> messages (getcmdtype() ==# ':' && getcmdline() ==# 'messages') ? 'lua Snacks.notifier.show_history()' : 'messages']])
