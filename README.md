# `Z.nvim`

A simple wrapper around the `z` shell program.

Confirmed to work with the following implementations:

- [`z.lua`](https://github.com/skywind3000/z.lua)
- [`zoxide`](https://github.com/ajeetdsouza/zoxide)

Open an issue/PR if a `z` implementation works/doesn't work 🙂.

## Installation/Setup

- [lazy.nvim](https://github.com/folke/lazy.nvim):

  ```lua
  {
    "PriceHiller/z.nvim",
    config = true,
    cmd = { "Z" }
  }
  ```

## Configuration

The default configuration is provided below (works with `z.lua`):

```lua
require("z").setup({
    z_cmd = { "z", "-e" },
    z_comp_cmd = { "z", "--complete" },
    z_dir_changed_cmd = { "z", "--add" },
})
```

A configuration for `zoxide`:

```lua
require("z").setup({
    z_cmd = function()
        return { "zoxide", "query", "--exclude", vim.fn.getcwd() }
    end,
    z_comp_cmd = function()
        return { "zoxide", "query", "--list", "--exclude", vim.fn.getcwd() }
    end,
    z_dir_changed_cmd = { "zoxide", "add" }
})
```

## Usage

`z.nvim` provides a single user command: `Z`. Type `Z` and a commonly visited directory to change the current directory to it.

Just like using `z` in the command line.
