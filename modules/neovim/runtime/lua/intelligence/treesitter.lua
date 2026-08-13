local ok, treesitter = pcall(require, "nvim-treesitter")
if ok then
  treesitter.setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
  })
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
  callback = function(args)
    local started = pcall(vim.treesitter.start, args.buf)
    if started then
      vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.wo[0][0].foldmethod = "expr"
    end
  end,
})

local textobjects_ok, textobjects = pcall(require, "nvim-treesitter-textobjects")
if textobjects_ok then
  textobjects.setup({
    move = {
      set_jumps = true,
    },
  })

  local move = require("nvim-treesitter-textobjects.move")

  -- These MUST be buffer-local and set after 'ftplugin'. Neovim's built-in
  -- python and markdown ftplugins map [[ ]] [m ]m buffer-locally with regex
  -- implementations, and a buffer-local map beats a global one — so the global
  -- versions never fired in exactly the two filetypes used most here.
  -- vim.schedule pushes this past both ftplugin and after/ftplugin.
  local motions = {
    { "]m", move.goto_next_start,     "@function.outer", "Next function start" },
    { "[m", move.goto_previous_start, "@function.outer", "Previous function start" },
    { "]]", move.goto_next_start,     "@class.outer",    "Next class start" },
    { "[[", move.goto_previous_start, "@class.outer",    "Previous class start" },
  }

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("TreesitterMotions", { clear = true }),
    callback = function(args)
      local buf = args.buf
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        if not vim.treesitter.get_parser(buf, nil, { error = false }) then
          return
        end
        for _, m in ipairs(motions) do
          local lhs, fn, capture, desc = m[1], m[2], m[3], m[4]
          vim.keymap.set({ "n", "x", "o" }, lhs, function()
            fn(capture, "textobjects")
          end, { buffer = buf, desc = desc })
        end
      end)
    end,
  })
end

local ctx_ok, ts_context = pcall(require, "treesitter-context")
if ctx_ok then
  ts_context.setup({
    max_lines = 3,
  })
end
