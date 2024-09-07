# `Z.nvim`

A simple wrapper around the `z` shell program.

Confirmed to work with the following implementations:

- [`z.lua`](https://github.com/skywind3000/z.lua)

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

The default configuration is provided below:

```lua
require("z").setup({
  z_cmd = "z",
  use_dir_changed = true
})
```

## Usage

`z.nvim` provides a single user command: `Z`. Type `Z` and a commonly visited directory to change the current directory to it.

Just like using `z` in the command line.
