local M = {}

local config = require('head.config').config
local info = require 'head.info'
local date = require 'head.date'

-- stylua: ignore start
local comment_chars = {
    ['//'] = {'c', 'cpp', 'cs', 'd', 'dart', 'dpr', 'fs', 'go', 'groovy', 'hx', 'java', 'js', 'jsx', 'kt', 'obj', 'php', 'rs', 'scala', 'swift', 'ts', 'tsx', 'v', 'vue', 'zig'},
    ['#']  = {'coffee', 'cr', 'ex', 'jl', 'nim', 'p6', 'ps1', 'py', 'r', 'raku', 'rb', 'sh'},
    ['--'] = {'ada', 'hs', 'lua', 'sql', 'vhdl'},
    [';;'] = {'clj', 'cljr', 'cljs', 'lsp', 'scm', 'sld', 'sls', 'sps'},
    ['%%'] = {'erl', 'pl', 'pro'},
    ['!']  = {'f', 'f90'},
    ['%']  = {'m', 'mat'},
    ['(*'] = {'ml', 'mli'},
    ["'"]  = {'vb', 'vbnet'},
    [';']  = {'asm'},
    ['*']  = {'cbl', 'cob'},
}
-- stylua: ignore end

function M.GetSymbols()
    local symbol_key = {
        ['@%na'] = 'name',
        ['@%us'] = 'username',
        ['@%em'] = 'email',
        ['@%fi'] = 'file',
        ['@%fp'] = 'first parent folder',
        ['@%pr'] = 'project',
        ['@%pa'] = 'path',
        ['@%dc'] = 'created date',
        ['@%dm'] = 'modified date',
    }

    print 'Symbol Key for Header Formats:'

    for symbol, description in pairs(symbol_key) do
        print(string.format('  %s: %s', symbol, description))
    end
end

function M.ReplaceSymbols(line)
    local function sanitize(str)
        return (str:gsub('[\r\n]', ''):gsub('^%s*(.-)%s*$', '%1'))
    end

    local replacements = {
        ['@%%na'] = sanitize(info.name()),
        ['@%%us'] = sanitize(info.user()),
        ['@%%em'] = sanitize(info.email()),
        ['@%%fi'] = sanitize(info.file()),
        ['@%%fp'] = sanitize(info.firstParent()),
        ['@%%pr'] = sanitize(info.project()),
        ['@%%pa'] = sanitize(info.path()),
        ['@%%dc'] = sanitize(date.createdDate()),
        ['@%%dm'] = sanitize(date.modifiedDate()),
    }

    for key, value in pairs(replacements) do
        line = string.gsub(line, key, value)
    end

    return line
end

function M.GetCommentChar()
    local filetype = vim.fn.expand '%:e'
    for comment_char, languages in pairs(comment_chars) do
        for _, lang in ipairs(languages) do
            if lang == filetype then
                return comment_char
            end
        end
    end
    return ''
end

function M.GetHeaderFormat(current)
    local function print_format(ft, format)
        print('Format for ' .. ft .. ':')
        for _, line in ipairs(format) do
            print('  ' .. line)
        end
        print ''
    end

    if current == true then
        local filetype = vim.fn.expand '%:e'
        local format = config.header[filetype] or config.header.default
        local used_ft = config.header[filetype] and filetype or 'default'

        print_format(used_ft, format)
    elseif current == nil then
        for ft, format in pairs(config.header) do
            print_format(ft, format)
        end
    else
        return config.header
    end
end

function M.ValidFileType()
    local comment_char = M.GetCommentChar()
    local valid = comment_char ~= ''

    if not valid then
        print 'File type not supported for headers.'
        return false
    end

    return true
end

return M
