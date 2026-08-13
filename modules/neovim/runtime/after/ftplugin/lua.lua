-- Lua localleader mappings.
local wk = require("which-key")
local buf = vim.api.nvim_get_current_buf()

wk.add({
  { "<localleader>", group = "Lua", buffer = buf },
})

vim.keymap.set("n", "<localleader>x", function() vim.cmd("source %") end, { buffer = buf, desc = "Run file" })
vim.keymap.set("n", "<localleader>l", function() vim.cmd("lua " .. vim.api.nvim_get_current_line()) end, { buffer = buf, desc = "Run line" })
vim.keymap.set("n", "<localleader>s", function() vim.notify(vim.inspect(vim.v.completed_item)) end, { buffer = buf, desc = "Inspect symbol" })
-- `<localleader>e`, not `<localleader>p`: `p` is Peek definition from the LSP
-- layer, and LspAttach vs FileType order is not fixed, so sharing the key made
-- the winner depend on which fired last.
vim.keymap.set("n", "<localleader>e", function()
  local line = vim.api.nvim_get_current_line()
  local ok, val = pcall(load("return " .. line))
  if ok then vim.notify(vim.inspect(val)) else vim.notify(tostring(val), vim.log.levels.WARN) end
end, { buffer = buf, desc = "Evaluate expression" })
