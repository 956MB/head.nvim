local M = {}

local config = require('head.config').config
local utils = require 'head.utils'
local core = require 'head.core'

function M.setupAutocmd()
    local augroup = vim.api.nvim_create_augroup('HeadNvimGroup', { clear = true })

    if config.auto_add then
        -- vim.api.nvim_create_autocmd('BufEnter', {
        --     group = augroup,
        --     callback = function()
        --         if utils.ValidFileType() and not core.HasHeader() then
        --             local new_header = core.NewHeader()
        --             core.AddHeader(new_header)
        --         end
        --     end,
        -- })
    end

    if config.auto_update then
        -- vim.api.nvim_create_autocmd('BufWritePre', {
        --     nested = true,
        --     group = augroup,
        --     callback = function()
        --         core.UpdateHeader()
        --     end,
        -- })
    end
end

return M
