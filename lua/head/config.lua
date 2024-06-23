local M = {}

M.config = {
    -- Automatically updates info within the header when saving the file
    auto_update = false,
    -- Automatically adds a header to a new file when creating it or when opening a file without a header
    auto_add = false,
    -- Format used for the `@%dc` and `@%dm` symbols (date_created and date_modified)
    date_format = '%m/%d/%y', -- other formats: '%m/%d/%y %H:%M:%S', '%Y-%m-%d %H:%M:%S'
    -- 'Backup' or manually set username, name, and email
    user = 'username',
    name = 'name',
    email = 'e@mail.com',
    -- Used later for calling the git command and getting various infos
    git = {
        enabled = true,
        bin = 'git',
    },
    -- Object containing the default header format and ones for each filetype
    header = {
        -- `default` used as the fallback for all filetypes, other files types can be added here with `ft = { ... }` -> `lua = { ... }`
        default = {
            '',
            '  @%fi',
            '  @%pr',
            '',
            '  Created by @%na on @%dc',
            '',
        },
    },
}

function M._ValidateHeaderFormat(format)
    local valid_symbols = {
        '@%%na',
        '@%%us',
        '@%%em',
        '@%%fi',
        '@%%fp',
        '@%%pr',
        '@%%pa',
        '@%%dc',
        '@%%dm',
    }

    for _, line in ipairs(format) do
        local remaining = line

        for _, symbol in ipairs(valid_symbols) do
            remaining = remaining:gsub(symbol:gsub('%%', '%'), '')
        end

        if remaining:match '@%%' then
            local invalid_symbol = remaining:match '@%%(%w+)'
            error(string.format("Invalid symbol '@%%%s' in header format", invalid_symbol))
        end
    end

    return true
end

function M._ValidateHeaderConfig()
    for ft, format in pairs(M.config.header) do
        local success, result = pcall(M._ValidateHeaderFormat, format)

        if not success then
            vim.notify(string.format("Invalid header format for filetype '%s': %s", ft, result), vim.log.levels.WARN)
            M.config.header[ft] = M.config.header.default
            vim.notify(string.format("Falling back to default header format for filetype '%s'", ft), vim.log.levels.INFO)
        end
    end
end

function M.setup(user_config)
    M.config = vim.tbl_deep_extend('force', M.config, user_config or {})

    M._ValidateHeaderConfig()

    require('head.commands').setupCommands()
    require('head.autocmd').setupAutocmd()
end

return M
