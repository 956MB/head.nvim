local M = {}

local config = require('head.config').config
local utils = require 'head.utils'

function M.NewHeader()
    local filetype = vim.fn.expand '%:e'
    local header_format = config.header[filetype] or config.header.default
    local comment_char = utils.GetCommentChar()
    local header = {}

    for _, line in ipairs(header_format) do
        local new_line = utils.ReplaceSymbols(line)
        table.insert(header, comment_char .. ' ' .. new_line)
    end

    table.insert(header, '')
    return header
end

function M.UpdateHeader()
    if not utils.ValidFileType() then
        return
    end

    M.RemoveHeader()

    local new_header = M.NewHeader()
    local buf = vim.api.nvim_get_current_buf()
    M.AddHeader(new_header, buf)
end

function M.AddHeader(header, buf)
    if not utils.ValidFileType() then
        return
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    -- print('Header:\n' .. table.concat(header, '\n'))

    vim.api.nvim_buf_set_lines(buf, 0, 0, false, header)
    vim.api.nvim_buf_set_lines(buf, #header, -1, false, lines)

    -- print(string.format('Header added to file %s successfully.', vim.fn.expand '%:t'))
end

function M.RemoveHeader()
    -- BUG: I currently had a test header set (length 11), and reloading the config to then use the default header (length 5)
    -- caused a length of 5 to be used to remove the header from the top of the file, which left 6 lines of the test header
    -- inside the rest of the buffer. So maybe a more "sophisticated" way of removing the header is needed, like counting the
    -- number of lines at the top of the file and "soft" comparing it to the defined headers in the cofig... then remove it.
    -- ...
    -- Same could also be bad if too many lines are added to a header format and normal code is deleted.
    if utils.ValidFileType() and M.HasHeader() then
        vim.api.nvim_buf_set_lines(0, 0, M.GetHeaderLength() + 1, false, {})
    end
end

function M.HasHeader(print_output)
    if not utils.ValidFileType() then
        return false
    end

    local filename = vim.fn.expand '%:t'
    local filetype = vim.fn.expand '%:e'
    local header_format = config.header[filetype] or config.header.default
    local comment_style = utils.GetCommentChar()

    local file_lines = vim.api.nvim_buf_get_lines(0, 0, #header_format, false)

    if #file_lines < #header_format then
        if print_output then
            print(string.format("File '%s' does not have enough lines for a header.", filename))
        end

        return false
    end

    for i, line in ipairs(file_lines) do
        if not line:match('^%s*' .. vim.pesc(comment_style)) then
            if print_output then
                print(string.format("File '%s' does not have a valid header. Line %d is not a comment.", filename, i))
            end

            return false
        end
    end

    if print_output then
        print(string.format("File '%s' has a valid header.", filename))
    end

    return true
end

function M.CollapseHeader() end

function M.GetHeaderLength()
    local filetype = vim.fn.expand '%:e'
    local header_format = config.header[filetype] or config.header.default
    return #header_format
end

function M.GetHeader()
    if utils.ValidFileType() and M.HasHeader() then
        local header_len = M.GetHeaderLength()
        local header = vim.api.nvim_buf_get_lines(0, 0, header_len, false)
        print(table.concat(header, '\n'))
    else
        print 'No header found or invalid file type.'
    end
end

return M
