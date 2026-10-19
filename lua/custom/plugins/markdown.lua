-- Markdown rendered in-buffer (headings, tables, callouts, code blocks)
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }

require('render-markdown').setup {
  file_types = { 'markdown', 'codecompanion' },
}
vim.keymap.set('n', '<leader>tm', '<Cmd>RenderMarkdown toggle<CR>', { desc = '[T]oggle [M]arkdown render' })

-- Prose: one paragraph = one line, so move by screen line, not file line
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'text' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    for _, k in ipairs { 'j', 'k', '0', '$' } do
      vim.keymap.set({ 'n', 'x' }, k, 'g' .. k, { buffer = true })
    end
  end,
})
