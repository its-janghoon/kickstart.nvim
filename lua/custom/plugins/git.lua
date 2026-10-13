-- Git: lazygit in a floating window (needs the `lazygit` binary on PATH)
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'nvim-lua/plenary.nvim',
  gh 'kdheepak/lazygit.nvim',
}

vim.keymap.set('n', '<leader>gg', '<Cmd>LazyGit<CR>', { desc = 'Lazy[G]it' })
vim.keymap.set('n', '<leader>gf', '<Cmd>LazyGitCurrentFile<CR>', { desc = 'LazyGit current [F]ile' })
