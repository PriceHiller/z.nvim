---@alias z.cmd string[] | fun(): string[]

---@class z.ConfigOpts
---@field z_cmd? z.cmd The `z` command to invoke along with arguments or a function that returns the command, should return a single match
---@field z_comp_cmd? z.cmd The `z` comp command along with arguments or a function that returns the command, should return multiple matches
---@field z_dir_changed_cmd? z.cmd The `z` command to add directories from DirChanged events

---@class z.Config:z.ConfigOpts
---@field z_cmd z.cmd The `z` command to invoke along with arguments or a function that returns the command, should return a single match
---@field z_comp_cmd z.cmd The `z` comp command along with arguments or a function that returns the command, should return multiple matches
---@field z_dir_changed_cmd? z.cmd The `z` command to add directories from DirChanged events
local Config = {
    z_cmd = { "z", "-e" },
    z_comp_cmd = { "z", "--complete" },
    z_dir_changed_cmd = { "z", "--add" },
}

---@type z.ConfigOpts
local default_config = vim.deepcopy(Config)

---Update z's configuration with new options
---@param config z.ConfigOpts
function Config:update(config)
    local new = vim.tbl_deep_extend("force", self, config)
    for k, v in pairs(new) do
        self[k] = v
    end
end

function Config:reset()
    Config:update(Config:get_defaults())
end

---@return z.ConfigOpts
function Config:get_defaults()
    return vim.deepcopy(default_config)
end

return Config
