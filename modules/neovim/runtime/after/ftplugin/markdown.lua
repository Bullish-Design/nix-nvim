-- Markdown localleader.
--
-- The old vault guard here compared the buffer path against ~/Documents/Notes
-- while the vault actually lived at $LOCI_OBSIDIAN_VAULT (~/Notes), so it never
-- matched and vault files got this layer stacked on the obsidian one. loci now
-- owns notes, so there is no second layer to dodge and no guard to get wrong.
local ok_wk, wk = pcall(require, "which-key")
local buf = vim.api.nvim_get_current_buf()

if ok_wk then
  wk.add({
    { "<localleader>", group = "Markdown", buffer = buf },
  })
end

-- `<localleader>v`, not `<localleader>p`: `p` is Peek definition from the LSP
-- layer, and LspAttach vs FileType order is not fixed, so sharing the key made
-- the winner depend on which fired last.
--
-- md-render exposes no top-level `toggle`; the previous `require("md-render").toggle()`
-- raised on every press. The preview API is `.preview.toggle()` (`:MdRender toggle`).
vim.keymap.set("n", "<localleader>v", function() require("md-render").preview.toggle() end,
  { buffer = buf, desc = "Preview toggle" })
