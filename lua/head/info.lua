local M = {}

local config = require('head.config').config

function M.user()
    return config.git.enabled and M._gitUser() or config.user
end

function M.name()
    return config.git.enabled and M._gitName() or config.name
end

function M.email()
    return config.git.enabled and M._gitEmail() or config.email
end

function M.file()
    return vim.fn.expand '%:t'
end

function M.firstParent()
    local current_file = vim.fn.expand '%:p'
    local current_dir = vim.fn.fnamemodify(current_file, ':h')
    local first_parent = vim.fn.fnamemodify(current_dir, ':t')
    return first_parent .. '/'
end

function M.project()
    local project = config.git.enabled and M._gitProject() or M._firstParent()
    return project .. '/'
end

function M.path()
    return vim.fn.expand '%:p'
end

function M._gitUser()
    local remote_url = vim.fn.system(config.git.bin .. ' config --get remote.origin.url')
    local github_username = string.match(remote_url, 'https://github.com/([%w-_]+)/')
    return github_username or ''
end

function M._gitName()
    return vim.fn.system(config.git.bin .. ' config user.name')
end

function M._gitEmail()
    return vim.fn.system(config.git.bin .. ' config user.email')
end

function M._gitProject()
    local current_file = vim.fn.expand '%:p'
    local current_dir = vim.fn.fnamemodify(current_file, ':h')

    while current_dir ~= '/' do
        local git_dir = current_dir .. '/.git'
        if vim.fn.isdirectory(git_dir) == 1 then
            local project_name = vim.fn.fnamemodify(current_dir, ':t')
            return project_name
        end
        current_dir = vim.fn.fnamemodify(current_dir, ':h')
    end

    return ''
end

return M
