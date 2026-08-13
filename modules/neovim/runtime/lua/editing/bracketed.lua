require("mini.bracketed").setup({
  treesitter = { suffix = "" },  -- disable [t/]t, we use these for tabs
  -- yanky owns the yank ring (<C-n>/<C-p>, with history + put-highlight).
  -- mini.bracketed's [y/]y is a second, independent ring over the same yanks.
  yank = { suffix = "" },
})
