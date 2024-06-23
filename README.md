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

- More dynamic values could be added to the header format.

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
    auto_update = false,
    auto_add = false,
    date_format = '%m/%d/%y',
    user = 'username',
    name = 'name',
    email = 'e@mail.com',
    git = {
        enabled = true,
        bin = 'git',
    },
    header = {
        -- The default format matches the header given to files in Xcode...
        -- but you can change this to anything you like.
        default = {
            '',
            '  @%f',
            '  @%p',
            '',
            '  Created by @%n on @%dc',
            '',
        },
        -- Add other language-specific headers here
    },
}
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

## License

[MIT](./LICENSE)
