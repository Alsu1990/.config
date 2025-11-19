local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action
local config = wezterm.config_builder()

-- Reload the configuration every 10 minutes
wezterm.time.call_after(10 * 60, function()
    wezterm.reload_configuration()
end)

-- Util Functions --------------------------------------------------------------
function is_elevated()
    -- https://stackoverflow.com/a/52675587/851560
    local success, stdout, stderr = wezterm.run_child_process({
        "cmd.exe",
        "/d",
        "/s",
        "/c",
        "dir %SYSTEMROOT%\\System32\\WDI\\LogFiles",
    })
    return success
end

local is_elevated_cached = is_elevated()

function current_hour()
    return tonumber(wezterm.time.now():format("%H"))
end

function is_elevated()
    -- https://stackoverflow.com/a/52675587/851560
    local success, stdout, stderr = wezterm.run_child_process({
        "cmd.exe",
        "/d",
        "/s",
        "/c",
        "dir %SYSTEMROOT%\\System32\\WDI\\LogFiles",
    })
    return success
end
local is_elevated_cached = is_elevated()

-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
-- licensed under the terms of the LGPL2
-- http://lua-users.org/wiki/BaseSixtyFour
function base64_enc(data)
    local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    return (
        (data:gsub(".", function(x)
            local r, b = "", x:byte()
            for i = 8, 1, -1 do
                r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
            end
            return r
        end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
            if #x < 6 then
                return ""
            end
            local c = 0
            for i = 1, 6 do
                c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
            end
            return b:sub(c + 1, c + 1)
        end) .. ({ "", "==", "=" })[#data % 3 + 1]
    )
end

-- SSH -------------------------------------------------------------------------
-- Gets the SSH arguments a pane was launched with.
-- These are set using the `ssh_server` function.
function get_ssh_args(pane)
    local ssh_args = pane:get_user_vars().SSHArgs
    if not ssh_args then
        wezterm.log_error("Not an SSH connection")
        return nil
    end
    return wezterm.json_parse(ssh_args)
end

-- Given:
-- * `command`: A struct with an `args` field containing an array of command-line
--   arguments.
-- * `vars`: A table of user vars.
-- Modifies `command.args` so that it launches a process that first sets all
-- the given user vars in the pane, and then launches the original process.
function with_user_vars(command, vars)
    local quoted_command = wezterm.shell_join_args(command.args)

    local set_vars_string = ""
    for var_name, var_value in pairs(vars) do
        set_vars_string = set_vars_string
            .. string.format(
                "\027]1337;SetUserVar=%s=%s\007",
                var_name,
                base64_enc(var_value)
            )
    end

    command.args = {
        "powershell.exe",
        "-NonInteractive",
        "-NoLogo",
        "-NoProfile",
        "-Command",
        'Write-Host -NoNewline "'
            .. set_vars_string
            .. '"'
            .. '; [System.Environment]::CurrentDirectory = "C:\\"'
            .. "; "
            .. quoted_command,
    }

    return command
end

-- Given:
-- * `command`: A struct with `label` and `args` fields.
-- Modifies `command.args` so that the pane with the launched process has the
-- title specified in `command.label`.
-- The second part of this function is in the `format-tab-title` and
-- `format-window-title` event handlers.
function with_label(command)
    return with_user_vars(command, { TitleOverride = command.label })
end

-- Creates a `SpawnCommand` struct for connecting to an SSH server.
-- * `label`: The name to give to the tab when connecting to the server.
-- * `ssh_args`: A struct with the fields:
--   * `hostname` (required): The IP or hostname to connect to.
--   * `port` (optional): Port to connect on, instead of 22.
--   * `username` (optional): The username to connect with.
--   * `identity` (optional): Path to the SSH private key to use.
--   * `command` (optional): Command to run upon connecting to the server.
--                           Regardless of this value, the connection will be created
--                           with a TTY.
function ssh_server(label, ssh_args)
    local args = { "ssh", "-t" }

    if ssh_args.identity then
        table.insert(args, "-i")
        table.insert(args, ssh_args.identity)
    end

    if ssh_args.username then
        table.insert(args, "-l")
        table.insert(args, ssh_args.username)
    end

    if ssh_args.port then
        table.insert(args, "-p")
        table.insert(args, ssh_args.port)
    end

    table.insert(args, ssh_args.hostname)

    if ssh_args.command then
        table.insert(args, wezterm.shell_join_args(ssh_args.command))
    end

    local command = {
        label = label,
        args = args,
        cwd = wezterm.home_dir,
    }

    return with_user_vars(command, {
        TitleOverride = label,
        SSHArgs = wezterm.json_encode(ssh_args),
    })
end

-- Shorthand for connecting to a NextSilicon server/machine with tmux.
function ns_server(hostname, comment)
    local label = hostname
    if comment then
        label = label .. " (" .. comment .. ")"
    end
    return ssh_server(label, {
        username = "alexs",
        hostname = hostname,
        command = { "bash", "-lc", "tmux -u new -A -D -s main" },
    })
end

function msys2(env)
    return with_label({
        label = env .. " / MSYS2",
        args = {
            "C:/msys64/msys2_shell.cmd",
            "-defterm",
            "-here",
            "-no-start",
            "-" .. string.lower(env),
        },
        cwd = "C:/msys64/home/" .. os.getenv("USERNAME"),
    })
end

-- Obtains a given tab's title:
-- 1. If the `TitleOverride` user var is set in the active pane, it is used.
-- 2. Otherwise, the active pane's `.title` value is used.
function get_tab_title(tab)
    local title = tab.active_pane.user_vars.TitleOverride
    if not title then
        title = tab.active_pane.title
    end
    return title
end

wezterm.on(
    "format-tab-title",
    function(tab, tabs, panes, config, hover, max_width)
        return (tab.tab_index + 1) .. ": " .. get_tab_title(tab)
    end
)

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
    local zoomed = ""
    if tab.active_pane.is_zoomed then
        zoomed = "[Z] "
    end

    local administrator = ""
    if is_elevated_cached then
        administrator = "Administrator: "
    end

    local index = ""
    if #tabs > 1 then
        index = string.format("[%d/%d] ", tab.tab_index + 1, #tabs)
    end

    return administrator .. zoomed .. index .. get_tab_title(tab)
end)

-- Launches beyond-ssh when the `BeyondSSHPort` user var is changed.
-- See https://github.com/mbikovitsky/beyond-ssh#automation
wezterm.on("user-var-changed", function(window, pane, name, value)
    if name ~= "BeyondSSHPort" then
        return
    end

    local ssh_args = get_ssh_args(pane)
    if not ssh_args then
        return
    end

    local port = tonumber(value)
    if not port then
        wezterm.log_error("Not a valid port number")
        return
    end

    args = {
        "py",
        "C:\\Shortcuts\\beyond-ssh\\beyond_ssh.py",
        "connect",
    }

    if ssh_args.username then
        table.insert(args, "-u")
        table.insert(args, ssh_args.username)
    end

    table.insert(args, ssh_args.hostname)
    table.insert(args, port)

    wezterm.background_child_process(args)
end)

function get_corner_image()
    local config = {
        repeat_x = "NoRepeat",
        repeat_y = "NoRepeat",
        vertical_align = "Bottom",
        vertical_offset = "-2cell",
        horizontal_align = "Right",
        horizontal_offset = "-2cell",
        opacity = 0.1,
    }

    if current_hour() >= 17 or current_hour() < 9 then
        config.source = { File = wezterm.config_dir .. "/clippy_sleepy.png" }
        config.width = 94
        config.height = 83
    else
        config.source = { File = wezterm.config_dir .. "/clippy_normal.png" }
        config.width = 94
        config.height = 86
    end

    return config
end

local scheme = "Atelier Forest (base16)"
-- local scheme = 'GitHub Dark Gogh'
-- local scheme = 'GitHub Dark'

-- Configuration ---------------------------------------------------------------
return {
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    color_scheme = scheme,
    font = wezterm.font_with_fallback({
        "FiraCode Nerd Font",
        "Cascadia Code",
        "Consolas",
        "Courier New",
    }),
    window_background_opacity = 0.75,
    -- default_cursor_style = 'SteadyBar',

    front_end = "WebGpu",

    initial_cols = 140,
    initial_rows = 40,
    scrollback_lines = 50000,
    enable_scroll_bar = true,
    enable_wayland = false,
    selection_word_boundary = " \t\n{}[]()\"'`|│",

    background = {
        {
            source = {
                Color = wezterm.get_builtin_color_schemes()[scheme]["background"],
            },
            width = "100%",
            height = "100%",
        },
        get_corner_image(),
    },

    keys = {
        {
            key = "l",
            mods = "ALT",
            action = wezterm.action.ShowLauncherArgs({
                flags = "LAUNCH_MENU_ITEMS",
            }),
        },

        -- https://github.com/wez/wezterm/issues/606#issuecomment-1238029207
        {
            key = "c",
            mods = "CTRL",
            action = wezterm.action_callback(function(window, pane)
                local selection_text = window:get_selection_text_for_pane(pane)
                local is_selection_active = string.len(selection_text) ~= 0
                if is_selection_active then
                    window:perform_action(
                        wezterm.action.CopyTo("Clipboard"),
                        pane
                    )
                else
                    window:perform_action(
                        wezterm.action.SendKey({ key = "c", mods = "CTRL" }),
                        pane
                    )
                end
            end),
        },
        {
            key = "v",
            mods = "CTRL|SHIFT",
            action = wezterm.action.PasteFrom("Clipboard"),
        },
        {
            key = "_",
            mods = "CTRL|SHIFT",
            action = wezterm.action.DisableDefaultAssignment,
        },

        -- Connects to the current SSH server (as created by `ssh_server`) in a new pane
        -- on the right, and opens bottom (https://lib.rs/crates/bottom).
        -- The pane split is 2/3 : 1/3
        {
            key = "F9",
            mods = "ALT",
            action = wezterm.action_callback(function(win, pane)
                local ssh_args = get_ssh_args(pane)
                if not ssh_args then
                    return
                end

                ssh_args.command = {
                    "sh",
                    "-c",
                    "if command -v btm ; then btm ; else htop ; fi",
                }
                local command = ssh_server(
                    pane:get_user_vars().TitleOverride .. ": bottom",
                    ssh_args
                )
                command.direction = "Right"
                command.size = 0.333

                pane:split(command)
            end),
        },
        {
            key = "w",
            mods = "CTRL|SHIFT",
            action = wezterm.action.CloseCurrentPane({ confirm = true }),
        },
        {
            key = "w",
            mods = "SUPER",
            action = wezterm.action.CloseCurrentPane({ confirm = true }),
        },
        {
            key = "F4",
            mods = "CTRL",
            action = wezterm.action.CloseCurrentTab({ confirm = true }),
        },
    },

    mouse_bindings = {
        {
            event = { Down = { streak = 1, button = "Right" } },
            mods = "NONE",
            action = wezterm.action.PasteFrom("Clipboard"),
        },
    },

    exit_behavior = "CloseOnCleanExit",

    default_prog = with_label({
        label = "PowerShell",
        args = { "powershell.exe" },
    }).args,

    launch_menu = {
        with_label({
            label = "Command Prompt",
            args = { "cmd.exe" },
            set_environment_variables = {
                PROMPT = "$E]7;file://localhost/$P$E\\$P$G",
            },
        }),
        -- For PowerShell, OSC7 is set in the user profile.
        -- If using oh-my-posh: https://ohmyposh.dev/docs/configuration/overview#general-settings
        with_label({ label = "PowerShell", args = { "powershell.exe" } }),
        with_label({ label = "IPython", args = { "ipython.exe" } }),

        ns_server("drammer"),
        ns_server("dev-sw02"),
        ns_server("dev-sw04", "Formerly f00f"),
        ns_server("dev-sw05", "Formerly foreshadow"),
        ns_server("spectre"),
        ns_server("spectre1"),
        ns_server("spectre2"),
        ns_server("spectre3"),
        ns_server("srv-nxt080", "Beyond the mountains of darkness"),

        -- FPGA lab
        ns_server("marvin-amd-02", "VPK180 Versal"),
        ns_server("marvin-intel-06", "HAPS-100"),
        ns_server("marvin-intel5-08", "HAPS-100"),
        ns_server("marvin-intel5-15", "HAPS-100"),
        ns_server("marvin-intel5-11", "HAPS-100"),
        ns_server("marvin-amd-01", "HAPS-80"),
        ns_server("marvin-amd-05", "HAPS-80"),
        ns_server("marvin-amd-04", "HAPS-80"),
        ns_server("marvin-intel5-17", "HAPS-80"),


        ssh_server("Zebu", {
            username = "alexs",
            hostname = "zebu",
            command = { "bash", "-lc", "tmux -u new -A -D -s main" },
        }),

        ssh_server("Veloce VM", {
            username = "debian",
            hostname = "192.168.20.1",
            port = 25195,
            command = { "tmux", "-u", "new", "-A", "-D", "-s", "main" },
        }),

        msys2("MINGW64"),
        msys2("MINGW32"),
        msys2("CLANG64"),
        msys2("CLANG32"),
        msys2("MSYS"),
    },
}
