local M = {}

local core = require 'head.core'
local utils = require 'head.utils'

local function command(name, func, opts)
    return { name = name, func = func, opts = opts }
end

M.commands = {
    command('HeadUpdate', core.UpdateHeader, { desc = 'Updates header or adds new one to current file.' }),
    command('HeadRemove', core.RemoveHeader, { desc = 'Removes header currently in the file, if it has one.' }),
    command('HeadCheck', function()
        core.HasHeader(true)
    end, { desc = 'Checks and reports if current file has a header.' }),
    command('HeadCollapse', core.CollapseHeader, { desc = 'tly in the file, if it has one.' }),
    command('HeadGet', core.GetHeader, { desc = 'Returns the header in the current file, if it has one.' }),
    command('HeadConfig', function()
        utils.GetHeaderFormat()
    end, { desc = 'Prints all defined header formats in your plugin config.' }),
    command('HeadConfigCurrent', function()
        utils.GetHeaderFormat(true)
    end, { desc = 'Prints the header format for the current file type.' }),
    command('HeadSymbols', utils.GetSymbols, { desc = 'Prints the symbol key for header formats.' }),
}

function M.setupCommands()
    for _, cmd in ipairs(M.commands) do
        vim.api.nvim_create_user_command(cmd.name, cmd.func, cmd.opts)
    end
end

return M
