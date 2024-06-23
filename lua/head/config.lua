local M = {}

M.config = {
    auto_update = false,
    auto_add = false,
    date_format = '%m/%d/%y', -- other formats: '%m/%d/%y %H:%M:%S', '%Y-%m-%d %H:%M:%S'

    user = 'username',
    name = 'name',
    email = 'e@mail.com',

    git = {
        enabled = true,
        bin = 'git',
    },

    -- TODO: Util
    --    @%m:     margin
    --      - fills space up to the max width line with spaces " "
    --    @%r(s):  repeat(symbol)
    --      - (works like margin) repeating symbol fills the line full width, rather than a set amount of characters like "+ --- +" (which is 3 only)
    --    @%rc(s,c): repeat_count(symbol, count)
    --      - repeats the symbol a set amount of times, like "+ --- +": @%rc(-, 3)

    header = {
        default = {
            '',
            '  @%fi',
            '  @%pr',
            '',
            '  Created by @%na on @%dc',
            '',
        },
        test = {
            '+ ----------------- +',
            '+ @%na +',
            '+ @%us +',
            '+ @%em +',
            '+ @%fi +',
            '+ @%fp +',
            '+ @%pr +',
            '+ @%pa +',
            '+ @%dc +',
            '+ @%dm +',
            '+ ----------------- +',
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
