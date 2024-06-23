local M = {}

local config = require('head.config').config

local function getStatCommand()
    local os_name = vim.loop.os_uname().sysname
    if os_name == 'Darwin' then -- macOS
        return 'stat -f "%SB" -t "%Y-%m-%d %H:%M:%S"'
    elseif os_name == 'Linux' then
        return 'stat -c "%y"'
    else
        return nil -- Unsupported OS
    end
end

local function parseDate(date_str)
    local year, month, day, hour, min, sec = date_str:match '(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)'

    return {
        year = tonumber(year) or 1970,
        month = tonumber(month) or 1,
        day = tonumber(day) or 1,
        hour = tonumber(hour) or 0,
        min = tonumber(min) or 0,
        sec = tonumber(sec) or 0,
    }
end

function M.createdDate()
    local current_file = vim.fn.expand '%:p'
    local stat_cmd = getStatCommand()

    if stat_cmd then
        local cmd = stat_cmd .. ' "' .. current_file .. '"'
        local creation_date_str = vim.fn.system(cmd):gsub('%s+$', '')

        if vim.v.shell_error == 0 then
            local timestamp = os.time(parseDate(creation_date_str))

            if timestamp then
                return os.date(config.date_format, timestamp)
            end
        end
    end

    return M.modifiedDate()
end

function M.modifiedDate()
    local current_file = vim.fn.expand '%:p'
    local modified_date = vim.fn.getftime(current_file)

    if modified_date == 0 then
        modified_date = os.time()
    end

    return os.date(config.date_format, modified_date)
end

return M
