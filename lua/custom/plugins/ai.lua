-- AI coding agents
--  * sidekick.nvim: run any AI CLI (claude, codex, gemini, copilot, opencode, ...)
--    in a side terminal, send file/selection/diagnostics as context.
--    CLI sessions live in tmux so they survive closing Neovim.
--    NES (Copilot "next edit suggestions") is off: it needs a Copilot login.
--  * codecompanion.nvim: chat + inline edits with diff review.
--    Default adapter is copilot; set `strategies.*.adapter` for anthropic/openai/ollama.
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'nvim-lua/plenary.nvim',
  gh 'folke/sidekick.nvim',
  gh 'olimorris/codecompanion.nvim',
}

-- [[ sidekick.nvim ]]
require('sidekick').setup {
  nes = { enabled = false },
  cli = {
    picker = 'telescope',
    mux = {
      backend = 'tmux',
      enabled = vim.fn.executable 'tmux' == 1,
      create = 'terminal',
    },
    -- Redrob Code is the default agent (`<leader>aa`). Needs `redrob` on PATH.
    tools = { redrob = { cmd = { 'redrob' } } },
  },
}
local sk = function() return require 'sidekick.cli' end
vim.keymap.set({ 'n', 't', 'i', 'x' }, '<C-.>', function() sk().focus() end, { desc = 'Sidekick focus' })
vim.keymap.set('n', '<leader>aa', function() sk().toggle { name = 'redrob', focus = true } end, { desc = 'Sidekick toggle Redrob Code' })
vim.keymap.set('n', '<leader>ar', function() sk().toggle { name = 'redrob', focus = true } end, { desc = 'Sidekick [R]edrob Code' })
vim.keymap.set('n', '<leader>as', function() sk().select() end, { desc = 'Sidekick [S]elect CLI' })
vim.keymap.set('n', '<leader>ad', function() sk().close() end, { desc = 'Sidekick [D]etach session' })
vim.keymap.set({ 'n', 'x' }, '<leader>at', function() sk().send { msg = '{this}' } end, { desc = 'Sidekick send [T]his' })
vim.keymap.set('n', '<leader>af', function() sk().send { msg = '{file}' } end, { desc = 'Sidekick send [F]ile' })
vim.keymap.set('x', '<leader>av', function() sk().send { msg = '{selection}' } end, { desc = 'Sidekick send [V]isual' })
vim.keymap.set({ 'n', 'x' }, '<leader>ap', function() sk().prompt() end, { desc = 'Sidekick [P]rompt' })
vim.keymap.set('n', '<leader>ac', function() sk().toggle { name = 'claude', focus = true } end, { desc = 'Sidekick [C]laude' })

-- [[ codecompanion.nvim ]]
-- Redrob Code speaks ACP (opencode-compatible), so reuse the opencode adapter.
-- Inline edit stays HTTP-only in CodeCompanion; chat edits files via ACP with a diff to accept.
require('codecompanion').setup {
  adapters = {
    acp = {
      redrob = function()
        return require('codecompanion.adapters').extend('opencode', {
          name = 'redrob',
          formatted_name = 'Redrob Code',
          commands = { default = { 'redrob', 'acp' } },
        })
      end,
    },
  },
  interactions = {
    chat = { adapter = 'redrob' },
  },
}
vim.keymap.set({ 'n', 'v' }, '<leader>cc', '<Cmd>CodeCompanionChat Toggle<CR>', { desc = 'CodeCompanion [C]hat' })
vim.keymap.set({ 'n', 'v' }, '<leader>ca', '<Cmd>CodeCompanionActions<CR>', { desc = 'CodeCompanion [A]ctions' })
vim.keymap.set('v', '<leader>ce', ":'<,'>CodeCompanion ", { desc = 'CodeCompanion inline [E]dit' })
vim.keymap.set('v', 'ga', '<Cmd>CodeCompanionChat Add<CR>', { desc = 'Add selection to CodeCompanion chat' })
