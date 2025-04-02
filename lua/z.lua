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

    -- NOTE: This handles legacy setups that might be passing the `z_cmd` as a string
    if type(config.z_cmd) == "string" then
        vim.deprecate(
            "Configuring the z_cmd as a string",
            "a list (flat table) instead",
            "at some time in the future",
            "z.nvim"
        )
        ---@diagnostic disable-next-line: assign-type-mismatch
        config.z_cmd = { config.z_cmd }
    end

    ---@param z_cmd z.cmd
    ---@vararg string
    ---@return string[]
    local function z_cmd_to_args(z_cmd, ...)
        ---@type string[]
        local cmd = {}
        if type(z_cmd) == "function" then
            cmd = z_cmd()
        else
            cmd = vim.deepcopy(z_cmd)
        end
        vim.list_extend(cmd, { ... })
        return cmd
    end

    ---@param cmd string The config value the executable is coming from
    ---@param program string The program to check for according to `vim.fn.executable`
    ---@return boolean is_executable If the program is exists and is executable
    local function is_executable(cmd, program)
        if vim.fn.executable(program) == 0 then
            notify.error(("The command specified for `%s`, `%s`, is not executable!"):format(cmd, program))
            return false
        end
        return true
    end

    for _, is_exec in ipairs {
        is_executable("z_cmd", z_cmd_to_args(config.z_cmd)[1]),
        is_executable("z_comp_cmd", z_cmd_to_args(config.z_comp_cmd)[1]),
        is_executable("z_dir_changed_cmd", z_cmd_to_args(config.z_dir_changed_cmd)[1]),
    } do
        if not is_exec then
            notify.error(
                "Refusing to setup, some specified commands were not executable! Ensure they are on your PATH and try again."
            )
            return
        end
    end

    local cached_z_listing = {}
    vim.api.nvim_create_user_command("Z", function(opts)
        local cmd = z_cmd_to_args(config.z_cmd, opts.args)

        local cmd_out = vim.system(cmd, { text = true }):wait()
        cmd_out.stdout = vim.trim(cmd_out.stdout or "")

        if cmd_out.code > 0 then
            notify.error("Failed with code `" .. cmd_out.code .. "`\nSTDERR: " .. (cmd_out.stderr or ""))
        elseif cmd_out.stdout == "" then
            notify.warn("Did not receive a match from `z`!")
        else
            local stripped_stdout = vim.trim(cmd_out.stdout)
            vim.cmd("silent! cd " .. stripped_stdout)
            notify.info("Chdir to `" .. stripped_stdout .. "`")
            -- On a successful change of directory, we should wipe out the cache
            cached_z_listing = {}
        end
    end, {
        nargs = "+",
        complete = function(_, _, _)
            ---@type string[]
            if #cached_z_listing == 0 then
                local cmd = z_cmd_to_args(config.z_comp_cmd)
                local cmd_out = vim.system(cmd, { text = true }):wait()
                if cmd_out.code == 0 and cmd_out.stdout then
                    cached_z_listing = vim.split(cmd_out.stdout, "\n")
                end
            end
            return cached_z_listing
        end,
        desc = "Invoke `z`",
    })

    if config.z_dir_changed_cmd then
        vim.api.nvim_create_autocmd("DirChanged", {
            callback = function(args)
                local cmd = z_cmd_to_args(config.z_dir_changed_cmd, args.file)
                vim.system(cmd, { text = true }, function(out)
                    if out.code ~= 0 then
                        notify.warn(
                            "Failed to regiser directory with `z`!\n====STDERR====\n"
                                .. out.stderr
                                .. "\n====STDOUT====\n"
                                .. out.stdout
                        )
                    end
                end)
                -- On a change of directory, wipe out the cache
                cached_z_listing = {}
            end,
        })
    end
end

M.Config = config

return M
