local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.colorcolumn = "120"
opt.cmdheight = 0
opt.showmode = false
opt.winborder = "rounded"
opt.showtabline = 2

opt.splitbelow = true
opt.splitright = true

-- Clipboard provider strategy, chosen by the nix wrapper (nix-nvim.neovim.clipboard):
--   osc52 → force the built-in OSC52 provider (default). No provider binary needed
--           on the server; copy/paste travels as an escape sequence over SSH and the
--           client terminal (kitty, alacritty, wezterm, iTerm2, Windows Terminal, …)
--           owns the real clipboard. Forcing it also skips provider auto-detection,
--           so no "No provider available" warning on headless boxes.
--   auto  → leave Neovim's provider auto-detection on (xclip/xsel/wl-copy/pbcopy…).
--           Right choice on graphical systems with a local display.
local clipboard_mode = vim.g.nix_nvim_clipboard or "osc52"
if clipboard_mode == "osc52" then
  vim.g.clipboard = "osc52"
end
opt.clipboard = "unnamedplus"

opt.foldlevel = 99
opt.foldlevelstart = 99

opt.swapfile = false
opt.backup = false
opt.undofile = true

opt.list = true
opt.listchars = { trail = "·", tab = "» " }

opt.sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize"

opt.updatetime = 250
opt.timeoutlen = 300
opt.mouse = "a"
opt.completeopt = "menu,menuone,noselect"
opt.shortmess:append("I")
