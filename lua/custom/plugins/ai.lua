-- AI coding agents
--  * sidekick.nvim: run any AI CLI (claude, codex, gemini, copilot, opencode, ...)
--    in a side terminal, send file/selection/diagnostics as context.
--    CLI sessions live in tmux so they survive closing Neovim.
--    NES (Copilot "next edit suggestions") is off: it needs a Copilot login.
--  * codecompanion.nvim: chat with diff review, on Redrob Code over ACP.
--  * <leader>ce: inline edit in the editor (Redrob Console API); <leader>aE: same text to the panel.
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
-- Chat runs on Redrob Code over ACP (opencode-compatible adapter).
-- Inline edit needs an HTTP adapter, so it talks to the Redrob Console API directly.
-- The key is read from `redrob auth login`'s store at request time; nothing is written here.
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
    http = {
      redrob_api = function()
        return require('codecompanion.adapters').extend('openai_compatible', {
          name = 'redrob_api',
          formatted_name = 'Redrob Console',
          env = {
            url = 'https://console.redrob.ai/api/backend',
            api_key = 'cmd:jq -r .redrob.key ~/.local/share/redrob/auth.json',
            chat_url = '/v1/chat/completions',
            models_endpoint = '/v1/models',
          },
          schema = { model = { default = 'claude-sonnet-5' } },
        })
      end,
    },
  },
  interactions = {
    chat = { adapter = 'redrob' },
    inline = { adapter = 'redrob_api' },
  },
}
vim.keymap.set({ 'n', 'v' }, '<leader>cc', '<Cmd>CodeCompanionChat Toggle<CR>', { desc = 'CodeCompanion [C]hat' })
vim.keymap.set({ 'n', 'v' }, '<leader>ca', '<Cmd>CodeCompanionActions<CR>', { desc = 'CodeCompanion [A]ctions' })
-- <leader>ce: edit in the editor. Visual: the selection, normal: the paragraph.
-- Type your own instruction at the prompt; the change shows as a diff (ga accept, gr reject).
vim.keymap.set('x', '<leader>ce', ":'<,'>CodeCompanion ", { desc = 'Inline [E]dit selection' })
vim.keymap.set('n', '<leader>ce', "vip:'<,'>CodeCompanion ", { desc = 'Inline [E]dit paragraph' })
-- <leader>aE: same text, but to the Redrob Code side panel (agent can read/edit other files).
-- On a cold start the TUI needs a few seconds before its input exists; text sent earlier is
-- dropped. So render the text now (while the selection exists), open the panel, and send once
-- the panel shows its footer.
local function edit_in_panel()
  local _, text = sk().render { msg = '{position}\n{selection}\n' }
  if not text or #text == 0 then return end
  local send = function() sk().send { name = 'redrob', text = text, focus = true } end
  if #require('sidekick.cli.state').get { name = 'redrob', started = true } > 0 then return send() end
  vim.cmd 'normal! \27'
  sk().show { name = 'redrob', focus = true }
  local tries = 0
  local timer = assert(vim.uv.new_timer())
  timer:start(300, 300, vim.schedule_wrap(function()
    tries = tries + 1
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[b].filetype == 'sidekick_terminal' then
        local lines = table.concat(vim.api.nvim_buf_get_lines(b, 0, -1, false), '\n')
        if lines:find('ctrl+p', 1, true) then
          timer:stop()
          timer:close()
          return send()
        end
      end
    end
    if tries > 60 then
      timer:stop()
      timer:close()
      vim.notify('Redrob Code did not start in time; press <leader>aE again', vim.log.levels.WARN)
    end
  end))
end
vim.keymap.set('x', '<leader>aE', edit_in_panel, { desc = 'Redrob panel: [E]dit selection' })
vim.keymap.set('n', '<leader>aE', function()
  vim.cmd 'normal! vip'
  edit_in_panel()
end, { desc = 'Redrob panel: [E]dit paragraph' })
-- Entering the sidekick panel always lands in terminal (insert) mode, so keys like `/`
-- reach Redrob Code instead of starting a Neovim search.
vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
  callback = function()
    if vim.bo.filetype == 'sidekick_terminal' then vim.cmd.startinsert() end
  end,
})
vim.keymap.set('v', 'ga', '<Cmd>CodeCompanionChat Add<CR>', { desc = 'Add selection to CodeCompanion chat' })
