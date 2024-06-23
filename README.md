# head.nvim

[Neovim](https://github.com/neovim/neovim) plugin for adding and auto updating file headers.

I'm aware that file headers is probably a solved problem as far as plugins go, but I wanted to make my own for fun, and wanted to practice Lua and Neovim plugin dev more on a project idea I actually thought up working in Xcode. This is a work in progress, and there are some known issues and features not yet implemented.

### Features

- Automatically add and update file headers (later).
- Customizable [header formats](#customizing-headers) for different file types.
- Dynamic header values with pre-defined [symbols](#header-symbols).
- Git integration (sort-of). More to be done here.

---

_Image to be added here :(_

---

### ⚠️ NOTICE, Known Issues, Missing Features and TODOs (for now):

- [`auto_update`](#default-configuration) and [`auto_add`](#default-configuration) are not tested yet, and I'm slightly wary about those function at the moment. I need to actually finish them.

- Removing a header from a file doesn't take into account the current header format vs the header in a file. Example: a `5` line long header could be in a file, but if the format changes and the new header is shorter OR longer, it could add/remove too many lines, messing up the area around the header.

- No default keymaps are set up yet.

- Git "integration" doesn't really exist, yet. It only gets the user name and email from the git config, and doesn't do anything else with git. I want to add more features here, like getting the last commit date, and maybe even the commit message.

- More dynamic values could be added to the header format, these were planned but not implemented yet:
    - `@%ma` - margin: would handle open space between lines and allow of lines to be all the same max len, creating a full box.
    - `@%rs(s)` and `@%rc(s,n)` - similar to margin, but repeats a give character `s` to either fill the line or repeat `n` times.
    - `@%g...` - various git values, like last commit date, commit message, etc.

## Install

#### Requirements

- [Neovim](https://github.com/neovim/neovim) >= 0.9.2

```lua
{ -- lazy.nvim
    "956MB/head.nvim",
    config = function()
        require('head').setup({
            -- configuration here
        })
    end,
}
```

### Default Configuration

```lua
{
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
```

## Keymaps

```lua
-- You can set up keymaps in the most basic way like this, or however you prefer:
vim.keymap.set('n', '<leader>hu', '<cmd>HeadUpdate<cr>', { desc = '[U]pdate [H]eader (add if missing)' })
vim.keymap.set('n', '<leader>hr', '<cmd>HeadRemove<cr>', { desc = '[R]emove [H]eader' })
vim.keymap.set('n', '<leader>hc', '<cmd>HeadCheck<cr>', { desc = '[C]heck if current file has a [H]eader' })

-- The other commands don't really need keymaps, but you can set them up if you want:
-- vim.keymap.set('n', '<leader>hg', '<cmd>HeadGet<cr>', { desc = '[G]et current file [H]eader' })
-- vim.keymap.set('n', '<leader>hs', '<cmd>HeadSymbols<cr>', { desc = '[S]how [H]eader symbols list' })
-- vim.keymap.set('n', '<leader>hc', '<cmd>HeadConfig<cr>', { desc = 'Get [H]eader [C]onfig (all)' })
-- vim.keymap.set('n', '<leader>hc', '<cmd>HeadConfigCurrent<cr>', { desc = 'Get [H]eader [C]onfig (current file type)' })
```

## Usage

### Commands

| Command | Action |
|---------|--------|
| `:HeadUpdate` | Updates header or adds a new one to the current file |
| `:HeadRemove` | Removes the header currently in the file, if it has one |
| `:HeadCheck` | Checks if the current file has a header |
| `:HeadGet` | Displays the header in the current file, if it has one |
| `:HeadConfig` | Prints all defined header formats in your plugin config |
| `:HeadConfigCurrent` | Prints the header format for the current file type |
| `:HeadSymbols` | Prints the symbol key for header formats |

### Header Symbols

These symbols correspond to the following dymanic values that can be updated inside the header:

| Symbol | Description | Example |
|--------|-------------|---------|
| `@%na` | name | First Last |
| `@%us` | username | username |
| `@%em` | email | e@mail.com |
| `@%fi` | file name | file.txt |
| `@%fp` | first parent folder | folder/ |
| `@%pr` | project root | project/ |
| `@%pa` | path | project/folder/file.txt |
| `@%dc` | created date | 01/01/01 |
| `@%dm` | modified date | 01/01/01 |

Use `:HeadSymbols` command to view this list in Neovim.

## Customizing Headers

You can customize headers for specific file types in your configuration, and layout the symbols as you want:

```lua
require('head').setup({
    header = {
        default = { ... },
        rs = {
            '+ ----------------- +',
            '+ @%fi +',
            '+ @%pr +',
            '',
            '+ Created: @%dc +',
            '+ Modified: @%dm +',
            '+ ----------------- +',
        },
        -- Add more file type specific headers here
    },
})
```

More examples of header formats (generated by [Claude 3.5 Sonnet](https://claude.ai/):


```lua
{
    minimal = {
        '@%fi',
        'Created: @%dc',
    },

    standard = {
        '----------------------------------------',
        'File: @%fi',
        'Author: @%na (@%us)',
        'Created: @%dc',
        'Modified: @%dm',
        '----------------------------------------',
    },

    detailed = {
        '/*',
        ' * File: @%fi',
        ' * Path: @%pa',
        ' * Project: @%pr',
        ' * Author: @%na <@%em>',
        ' * Created: @%dc',
        ' * Last Modified: @%dm',
        ' */',
    },

    simple_box = {
        '+------------------+',
        '| File: @%fi',
        '| Author: @%na',
        '| Created: @%dc',
        '+------------------+',
    },

    compact = {
        '// @%fi | @%us | @%dc | @%pr',
    },

    markdown_style = {
        '# @%fi',
        '',
        '- **Author:** @%na',
        '- **Created:** @%dc',
        '- **Modified:** @%dm',
        '- **Project:** @%pr',
        '',
        '## Description',
        '',
        '[Your file description here]',
    },

    code_block = {
        '/**',
        ' * File        : @%fi',
        ' * Author      : @%na (@%us)',
        ' * Created     : @%dc',
        ' * Modified    : @%dm',
        ' * Project     : @%pr',
        ' */',
    },

    hash_style = {
        '###########################',
        '# File    : @%fi',
        '# Author  : @%us',
        '# Created : @%dc',
        '# Project : @%pr',
        '###########################',
    },

    simple_lines = {
        '------------------------',
        '@%fi',
        'By: @%na',
        'On: @%dc',
        'In: @%pr',
        '------------------------',
    },

    minimal_info = {
        '@%fi - @%us - @%dc',
        '----------------------',
    },
}
```

## License

[MIT](./LICENSE)
