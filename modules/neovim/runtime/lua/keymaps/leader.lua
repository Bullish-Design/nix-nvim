-- Single declarative spec for ALL <leader>* mappings.
-- This file is the keymap reference — it reads like the which-key popup.
local wk = require("which-key")

wk.add({

  -- ── Find ─────────────────────────────────────────────────────────────
  { "<leader>f",       group = "Find" },
  { "<leader>ff",      function() Snacks.picker.files() end,        desc = "Files" },
  { "<leader><space>", function() Snacks.picker.files() end,        desc = "Files" },
  { "<leader>fg",      function() Snacks.picker.grep() end,         desc = "Grep" },
  { "<leader>/",       function() Snacks.picker.grep() end,         desc = "Grep" },
  { "<leader>fb",      function() Snacks.picker.buffers() end,      desc = "Buffers" },
  { "<leader>fh",      function() Snacks.picker.help() end,         desc = "Help" },
  { "<leader>fr",      function() Snacks.picker.recent() end,       desc = "Recent" },
  { "<leader>fk",      function() Snacks.picker.keymaps() end,      desc = "Keymaps" },
  { "<leader>fd",      function() Snacks.picker.diagnostics() end,  desc = "Diagnostics" },
  { "<leader>fc",      function() Snacks.picker.commands() end,     desc = "Commands" },
  { "<leader>fs",      function() Snacks.picker.lsp_symbols() end,           desc = "LSP symbols (document)" },
  { "<leader>fS",      function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP symbols (workspace)" },
  { "<leader>fG",      function() Snacks.picker.git_status() end,   desc = "Git status" },
  { "<leader>fw",      function() require("wayfinder").open() end,  desc = "Wayfinder" },
  { "<leader>fz",      function() require("zeal").search() end,     desc = "Zeal docs" },
  { "<leader>ft",      "<cmd>TodoQuickFix keywords=TODO,FIX,FIXME,NOTE,PERF,HACK,WARN,TEST<cr>", desc = "Todos" },

  -- ── Git ──────────────────────────────────────────────────────────────
  -- Hunk MOTION and hunk EDIT live on the bracket/`g` grammar that mini.diff
  -- owns: `[h`/`]h` prev/next, `[H`/`]H` first/last, `gh` apply, `gH` reset,
  -- `gh` hunk textobject. Do not mirror them onto <leader>g* — that is what
  -- made three keys point at one action while apply-hunk had none.
  { "<leader>g",  group = "Git" },
  { "<leader>gg", function() require("neogit").open() end,  desc = "Neogit" },
  { "<leader>gD", "<cmd>DiffviewOpen<cr>",                  desc = "Diffview" },
  { "<leader>gq", "<cmd>DiffviewClose<cr>",                 desc = "Close diffview" },
  { "<leader>gb", function() MiniGit.show_at_cursor() end,  desc = "Blame/show" },

  -- ── Workspace ────────────────────────────────────────────────────────
  { "<leader>w",  group = "Workspace" },
  { "<leader>w-", "<C-w>s", desc = "Split below" },
  { "<leader>w|", "<C-w>v", desc = "Split right" },

  -- Tab subgroup
  { "<leader>wt",  group = "Tab" },
  { "<leader>wtn", function()
      vim.cmd("tabnew")
      vim.api.nvim_feedkeys(":Tabby rename_tab ", "n", false)
    end,                                                                               desc = "New" },
  { "<leader>wtj", "<cmd>Tabby jump_to_tab<cr>",                                     desc = "Jump to" },
  { "<leader>wtr", ":Tabby rename_tab ",                                              desc = "Rename" },
  { "<leader>wtc", "<cmd>tabclose<cr>",                                               desc = "Close" },
  { "<leader>wto", "<cmd>tabonly<cr>",                                                desc = "Only this" },
  { "<leader>wtT", function() require("workspace.submodes").tab_nav() end,            desc = "Nav submode" },
  { "<leader>wtm", function() require("workspace.submodes").tab_move() end,           desc = "Move submode" },
  { "<leader>wtp", "<cmd>Tabby pick_window<cr>",                                      desc = "Pick window" },
  { "<leader>wtd", "<C-w>c",                                                          desc = "Close window" },
  { "<leader>wtz", function() Snacks.zoom() end,                                      desc = "Zoom" },
  { "<leader>wte", "<C-w>=",                                                          desc = "Equalize" },

  -- Buffer subgroup
  { "<leader>wb",  group = "Buffer" },
  { "<leader>wbb", function() require("bento.api").toggle_menu() end,                 desc = "Bento menu" },
  { "<leader>wbL", function() require("bento.api").toggle_lock() end,                 desc = "Lock buffer" },
  { "<leader>wbD", function() require("bento.api").close_all_buffers({ visible = false, locked = false }) end, desc = "Close hidden" },
  { "<leader>wbd", function() Snacks.bufdelete() end,                                 desc = "Delete" },

  -- Sidequest subgroup
  { "<leader>ws",  group = "Sidequest" },
  { "<leader>wst", function() require("sidequest").toggle({ focus = true }) end,                desc = "Toggle" },
  { "<leader>wsf", function() require("sidequest").focus() end,                                 desc = "Focus" },
  { "<leader>wsh", function() require("sidequest").home() end,                                  desc = "Home" },
  { "<leader>wsg", function() require("sidequest").open_tree("git", { focus = true }) end,      desc = "Git" },
  { "<leader>wss", function() require("sidequest").open_tree("sessions", { focus = true }) end, desc = "Sessions" },

  -- ── Quit / Session ───────────────────────────────────────────────────
  { "<leader>q",  group = "Quit/Session" },
  { "<leader>qq", "<cmd>quitall<cr>",                          desc = "Quit all" },
  { "<leader>qs", function() require("resession").load() end,   desc = "Restore session" },
  -- On a loci tab (vim.t.loci_workspace_id set) save the workspace session
  -- TAB-SCOPED: the generic resession.save() writes the GLOBAL flavor and would
  -- overwrite the loci-<id>.json session as global-scoped (the client loads those
  -- safely with reset=false + a warning, but the right save is tab-scoped — the
  -- same save_tab the client's deactivate flow uses).
  { "<leader>qS", function()
      local wid = vim.t.loci_workspace_id
      if wid then
        require("resession").save_tab("loci-" .. wid)
      else
        require("resession").save()
      end
    end, desc = "Save session" },
  { "<leader>qd", function() require("resession").delete() end, desc = "Delete session" },
  { "<leader>qD", function() require("resession").detach() end, desc = "Detach session" },
  { "<leader>qw", function() require("workspace.sessions").load_workspace() end,   desc = "Restore workspace" },
  { "<leader>qW", function() require("workspace.sessions").save_workspace() end,   desc = "Save workspace" },
  { "<leader>qx", function() require("workspace.sessions").delete_workspace() end, desc = "Delete workspace" },

  -- ── Search / Replace ─────────────────────────────────────────────────
  { "<leader>s",  group = "Search/Replace" },
  { "<leader>sr", function() require("grug-far").open() end, desc = "Grug-far" },

  -- ── Diagnostics ──────────────────────────────────────────────────────
  -- <leader>x holds LISTS and actions only. Diagnostic MOTION is `[d`/`]d`
  -- (mini.bracketed), which also gives you `[D`/`]D` for first/last.
  { "<leader>x",  group = "Diagnostics" },
  { "<leader>xd", vim.diagnostic.setloclist, desc = "Buffer list" },
  { "<leader>xq", vim.diagnostic.setqflist,  desc = "Workspace quickfix" },
  { "<leader>xw", function() require("wtf").ai() end,  desc = "WTF: explain diagnostic" },
  { "<leader>xs", function() require("wtf").search() end, desc = "WTF: search diagnostic" },

  -- ── Notes (annotations only — loci owns notes, see <leader>l) ────────
  { "<leader>n",  group = "Annotations" },
  { "<leader>na", function() require("haunt.api").annotate() end,    desc = "Add/edit annotation" },
  { "<leader>nl", function() require("haunt.picker").show() end,     desc = "List annotations" },
  { "<leader>n]", function() require("haunt.api").next() end,        desc = "Next annotation" },
  { "<leader>n[", function() require("haunt.api").prev() end,        desc = "Prev annotation" },

  -- ── UI toggles ───────────────────────────────────────────────────────
  { "<leader>u",  group = "UI toggle" },
  { "<leader>up", function() require("precognition").toggle() end,                          desc = "Precognition" },
  { "<leader>uh", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, desc = "Inlay hints" },

  -- ── Single-key actions ───────────────────────────────────────────────
  { "<leader>e", function() Snacks.explorer() end,                            desc = "Explorer" },
  { "<leader>;", function() require("sidequest").toggle({ focus = true }) end, desc = "Sidequest toggle" },
  { "<leader>.", function() Snacks.scratch() end,                              desc = "Scratch buffer" },
  { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer keymaps" },

  -- ── Terminal ─────────────────────────────────────────────────────────
  { "<A-i>", function() Snacks.terminal.toggle() end, desc = "Terminal toggle", mode = { "n", "t" } },

  { "<leader>l",  group = "Loci" },
  { "<leader>lp", "<cmd>LociPalette<cr>",    desc = "Command palette" },
  { "<leader>ls", "<cmd>LociStatus<cr>",     desc = "Status / context hub" },
  { "<leader>lw", "<cmd>LociWorkspaces<cr>", desc = "Switch workspace" },
  { "<leader>lP", "<cmd>LociProjects<cr>",   desc = "Projects" },
  { "<leader>ld", "<cmd>LociDoctor<cr>",     desc = "Doctor (findings)" },
  -- The single notes surface. These replace the deleted obsidian.nvim vault
  -- bindings one-for-one: LociSearch for <leader>ns, LociBacklinks for the
  -- old <localleader>b, LociDaily for <leader>nd.
  { "<leader>ln",  group = "Notes" },
  { "<leader>lnd", "<cmd>LociDaily<cr>",     desc = "Daily note" },
  { "<leader>lns", "<cmd>LociScratch<cr>",   desc = "Scratch note" },
  { "<leader>lnn", "<cmd>LociNote<cr>",      desc = "New note" },
  { "<leader>lnf", "<cmd>LociSearch<cr>",    desc = "Search notes" },
  { "<leader>lnb", "<cmd>LociBacklinks<cr>", desc = "Backlinks" },

})
