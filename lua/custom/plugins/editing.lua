-- Editing / navigation: oil (file manager as buffer), flash (jump), harpoon (pin files)
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'nvim-lua/plenary.nvim',
  gh 'stevearc/oil.nvim',
  gh 'folke/flash.nvim',
  { src = gh 'ThePrimeagen/harpoon', version = 'harpoon2' },
}

-- [[ oil.nvim ]] edit the filesystem like a buffer, `:w` applies
require('oil').setup {
  default_file_explorer = true,
  view_options = { show_hidden = true },
}
vim.keymap.set('n', '-', '<Cmd>Oil<CR>', { desc = 'Open parent directory (oil)' })
-- keep <leader>pv as "project view" but open oil instead of netrw
vim.keymap.set('n', '<leader>pv', '<Cmd>Oil<CR>', { desc = '[P]roject [V]iew (oil)' })

-- [[ flash.nvim ]] jump anywhere on screen with labels
require('flash').setup {}
vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash jump' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash treesitter' })
vim.keymap.set('o', 'r', function() require('flash').remote() end, { desc = 'Remote flash' })

-- [[ harpoon ]] pin a handful of files and jump between them
local harpoon = require 'harpoon'
harpoon:setup()
vim.keymap.set('n', '<leader>ma', function() harpoon:list():add() end, { desc = 'Harpoon [A]dd file' })
vim.keymap.set('n', '<leader>mm', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon [M]enu' })
for i = 1, 4 do
  vim.keymap.set('n', '<leader>' .. i, function() harpoon:list():select(i) end, { desc = 'Harpoon file ' .. i })
end
vim.keymap.set('n', '<leader>mp', function() harpoon:list():prev() end, { desc = 'Harpoon [P]rev' })
vim.keymap.set('n', '<leader>mn', function() harpoon:list():next() end, { desc = 'Harpoon [N]ext' })
