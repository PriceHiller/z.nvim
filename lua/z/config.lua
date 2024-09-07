---@class z.Config
---@field z_cmd string The `z` command to invoke
---@field use_dir_changed boolean Whether `OnDirChanged` events should register their directories to `z`
local Config = {
    z_cmd = "z",
    use_dir_changed = true,
}

local default_config = vim.deepcopy(Config)

---Update z's configuration with new options
---@param config z.Config
function Config:update(config)
    Config = vim.tbl_deep_extend("force", self, config)
end

function Config:reset()
    self:update(self:get_defaults())
end

function Config:get_defaults()
    return default_config
end

return Config
