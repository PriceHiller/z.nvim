local config = require("z.config")
local notify = require("z.notify")
local M = {}

local user_cmds_created = false

M.create_user_commands = function()
    if user_cmds_created then
        return
    end
    user_cmds_created = true
end

--- Set up the plugin config
---@param user_config z.Config?
M.setup = function(user_config)
    config:update(user_config or {})

    local cached_z_listing = {}
    vim.api.nvim_create_user_command("Z", function(opts)
        cached_z_listing = {}
        local cmd = { config.z_cmd, "-e", opts.args }
        local cmd_out = vim.system(cmd, { text = true }):wait()
        if cmd_out.code > 0 then
            notify.warn("Failed with code `" .. cmd_out.code .. "`\nSTDERR: " .. (cmd_out.stderr or ""))
        elseif cmd_out.stdout == "" then
            notify.warn("Did not receive a match from `z`!")
        else
            local stripped_stdout = cmd_out.stdout:gsub("\n$", "")
            vim.cmd("silent! cd " .. stripped_stdout)
            notify.info("Chdir to `" .. stripped_stdout .. "`")
        end
    end, {
        nargs = "+",
        complete = function(_, _, _)
            local cmd = { config.z_cmd, "--complete" }
            local cmd_out
            if #cached_z_listing == 0 then
                cmd_out = vim.system(cmd, { text = true }):wait()
                if cmd_out.code == 0 and cmd_out.stdout then
                    cached_z_listing = vim.split(cmd_out.stdout, "\n")
                end
            end
            return cached_z_listing
        end,
        desc = "Invoke `z`",
    })

    if config.use_dir_changed then
        vim.api.nvim_create_autocmd("DirChanged", {
            callback = function(args)
                vim.system({ "z", "--add", args.file }, { text = true }, function(out)
                    if out.code ~= 0 then
                        notify.warn(
                            "Failed to regiser directory with `z`!\n====STDERR====\n"
                                .. out.stderr
                                .. "\n====STDOUT====\n"
                                .. out.stdout
                        )
                    end
                end)
            end,
        })
    end
end

M.Config = config

return M
