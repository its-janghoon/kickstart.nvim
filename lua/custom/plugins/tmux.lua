-- tmux: <C-h/j/k/l> moves between Neovim splits AND tmux panes as one grid.
-- Pair with this in ~/.tmux.conf (see https://github.com/christoomey/vim-tmux-navigator):
--   is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
--   bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
--   bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
--   bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
--   bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'christoomey/vim-tmux-navigator' }

-- The plugin defines its own <C-h/j/k/l> maps; override kickstart's plain window maps.
vim.keymap.set('n', '<C-h>', '<Cmd>TmuxNavigateLeft<CR>', { desc = 'Move focus left (tmux-aware)' })
vim.keymap.set('n', '<C-j>', '<Cmd>TmuxNavigateDown<CR>', { desc = 'Move focus down (tmux-aware)' })
vim.keymap.set('n', '<C-k>', '<Cmd>TmuxNavigateUp<CR>', { desc = 'Move focus up (tmux-aware)' })
vim.keymap.set('n', '<C-l>', '<Cmd>TmuxNavigateRight<CR>', { desc = 'Move focus right (tmux-aware)' })
