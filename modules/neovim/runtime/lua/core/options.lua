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
--   auto  (default): use the local graphical provider when one is available in the
--         current session (wl-clipboard on Wayland, xclip/xsel on X11, pbcopy on
--         macOS, …); otherwise fall back to the built-in OSC 52 provider. This is
--         the portable policy: a desktop session gets direct clipboard access,
--         while an SSH/TUI session into a headless box has no local provider, so
--         copy/paste travels as an escape sequence to the client terminal (kitty,
--         alacritty, wezterm, iTerm2, Windows Terminal, …) instead of warning
--         about a missing provider.
--   osc52 → force the built-in OSC 52 provider and skip the local-provider check.
local function has_local_clipboard_provider()
  local wayland = vim.env.WAYLAND_DISPLAY ~= nil
  local x11 = vim.env.DISPLAY ~= nil
  return (wayland and vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1)
    or (x11 and (vim.fn.executable("xclip") == 1 or vim.fn.executable("xsel") == 1))
    or vim.fn.executable("pbcopy") == 1 -- macOS: no display gate needed
    or vim.fn.executable("clip.exe") == 1 -- WSL/Windows
end

local clipboard_mode = vim.g.nix_nvim_clipboard or "auto"
if clipboard_mode == "osc52" or (clipboard_mode == "auto" and not has_local_clipboard_provider()) then
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
