local M = {}

--- Notify the user with a message
---@param message string
---@param level integer?
local notify = function(message, level)
    vim.notify(message, level or vim.log.levels.INFO, {
        title = "z.nvim",
        ---@param win integer The window handle
        on_open = function(win)
            vim.api.nvim_set_option_value("filetype", "markdown", { buf = vim.api.nvim_win_get_buf(win) })
        end,
    })
end

--- Notify a user
---@param message string
M.info = function(message)
    notify(message, vim.log.levels.INFO)
end

--- Notify a user with a warning
---@param message string
M.warn = function(message)
    notify(message, vim.log.levels.WARN)
end

--- Notify a user with an error
---@param message string
M.error = function(message)
    notify(message, vim.log.levels.ERROR)
end

return M
