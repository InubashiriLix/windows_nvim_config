-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.api.nvim_set_hl(0, "MatchParen", { fg = "#FFD700", bg = "none", bold = true })
vim.api.nvim_set_hl(0, "MatchParenMatched", { fg = "#ADD8E6", bg = "none", bold = true })

-- fucking fzf
-- vim.g.lazyvim_picker = "fzf"

-- =================== RUST CONFIG =====================
-- LSP Server to use for Rust.
-- Set to "bacon-ls" to use bacon-ls instead of rust-analyzer.
-- only for diagnostics. The rest of LSP support will still be
-- provided by rust-analyzer.
vim.g.lazyvim_rust_diagnostics = "rust-analyzer"
vim.g.lazyvim_python_lsp = "pyright"
-- Set to "ruff_lsp" to use the old LSP implementation version.
vim.g.lazyvim_python_ruff = "ruff"

-- for the sql completion
vim.g.dbs = {
    dev = "mysql://root:Lix0123456789@localhost",
    staging = "mysql://root:Lix0123456789@localhost",
}

-- LSP Server to use for Rust.
-- Set to "bacon-ls" to use bacon-ls instead of rust-analyzer.
-- only for diagnostics. The rest of LSP support will still be
-- provided by rust-analyzer.
vim.g.lazyvim_rust_diagnostics = "rust-analyzer"

-- 设置缩进为 4 个空格
vim.opt.tabstop = 4 -- Tab 显示为 4 个空格
vim.opt.shiftwidth = 4 -- 自动缩进为 4 个空格
vim.opt.expandtab = true -- 将 Tab 转换为空格
vim.opt.softtabstop = 4 -- 输入 Tab 键时插入 4 个空格
