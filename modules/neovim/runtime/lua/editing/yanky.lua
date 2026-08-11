require("yanky").setup({
  ring = { history_length = 50 },
  highlight = { timer = 200 },
  -- yanky's focus-based system-clipboard sync (default on) reads the `+`
  -- register on every FocusLost/FocusGained. With clipboard=unnamedplus over an
  -- OSC 52 provider that is an unsolicited clipboard READ on every focus change:
  -- kitty's default clipboard_control prompts ("Allow it to do so, once?"), and
  -- zellij drops the query so nvim just times out. Disable it — cross-app
  -- recall lives in the client's clipboard history (noctalia/klipper), and the
  -- ring keeps all in-nvim yanks via TextYankPost.
  system_clipboard = { sync_with_ring = false },
})

-- Yanky remaps core put grammar (p/P), so these bypass the keymap registry
-- conflict warnings on built-in overrides by design.
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "Put after (yanky)" })
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { desc = "Put before (yanky)" })
vim.keymap.set("n", "<C-p>", "<Plug>(YankyPreviousEntry)", { desc = "Yanky: prev entry" })
vim.keymap.set("n", "<C-n>", "<Plug>(YankyNextEntry)", { desc = "Yanky: next entry" })
