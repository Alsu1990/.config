local wezterm = require("wezterm")

local config = wezterm.config_builder()
local mux = wezterm.mux
local act = wezterm.action

-- Configuration
config.font = wezterm.font("Fira Code")
-- config.color_scheme = 'GitHub Dark'
config.color_scheme = 'Nancy (terminal.sexy)'
config.enable_scroll_bar = true
config.window_background_opacity = 0.75
config.use_fancy_tab_bar = true
config.tab_max_width = 32
config.hide_tab_bar_if_only_one_tab = true
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }

-- config.leader = { key="w", mods="CTRL" }
-- Key Bindings
config.keys = {
    {
        key = "F12",
        mods = "NONE",
        action = wezterm.action({ EmitEvent = "toggle-leader" }),
    },
    {
        key = "a",
        mods = "LEADER|CTRL",
        action = wezterm.action({ SendString = "\x01" }),
    },
    {
        key = "-",
        mods = "LEADER",
        action = wezterm.action({
            SplitVertical = { domain = "CurrentPaneDomain" },
        }),
    },
    {
        key = "\\",
        mods = "LEADER",
        action = wezterm.action({
            SplitHorizontal = {
                domain = "CurrentPaneDomain",
            },
        }),
    },
    {
        key = "s",
        mods = "LEADER",
        action = wezterm.action({
            SplitVertical = { domain = "CurrentPaneDomain" },
        }),
    },
    {
        key = "v",
        mods = "LEADER",
        action = wezterm.action({
            SplitHorizontal = {
                domain = "CurrentPaneDomain",
            },
        }),
    },
    { key = "o", mods = "LEADER", action = "TogglePaneZoomState" },
    { key = "z", mods = "LEADER", action = "TogglePaneZoomState" },
    {
        key = "c",
        mods = "LEADER",
        action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }),
    },
    {
        key = "h",
        mods = "LEADER",
        action = wezterm.action({ ActivatePaneDirection = "Left" }),
    },
    {
        key = "j",
        mods = "LEADER",
        action = wezterm.action({ ActivatePaneDirection = "Down" }),
    },
    {
        key = "k",
        mods = "LEADER",
        action = wezterm.action({ ActivatePaneDirection = "Up" }),
    },
    {
        key = "l",
        mods = "LEADER",
        action = wezterm.action({ ActivatePaneDirection = "Right" }),
    },
    {
        key = "H",
        mods = "LEADER|SHIFT",
        action = wezterm.action({ AdjustPaneSize = { "Left", 5 } }),
    },
    {
        key = "J",
        mods = "LEADER|SHIFT",
        action = wezterm.action({ AdjustPaneSize = { "Down", 5 } }),
    },
    {
        key = "K",
        mods = "LEADER|SHIFT",
        action = wezterm.action({ AdjustPaneSize = { "Up", 5 } }),
    },
    {
        key = "L",
        mods = "LEADER|SHIFT",
        action = wezterm.action({ AdjustPaneSize = { "Right", 5 } }),
    },
    {
        key = "1",
        mods = "LEADER",
        action = wezterm.action({ ActivateTab = 0 }),
    },
    {
        key = "2",
        mods = "LEADER",
        action = wezterm.action({ ActivateTab = 1 }),
    },
    {
        key = "3",
        mods = "LEADER",
        action = wezterm.action({ ActivateTab = 2 }),
    },
    {
        key = "4",
        mods = "LEADER",
        action = wezterm.action({ ActivateTab = 3 }),
    },
    {
        key = "5",
        mods = "LEADER",
        action = wezterm.action({ ActivateTab = 4 }),
    },
    {
        key = "6",
        mods = "LEADER",
        action = wezterm.action({ ActivateTab = 5 }),
    },
    {
        key = "7",
        mods = "LEADER",
        action = wezterm.action({ ActivateTab = 6 }),
    },
    {
        key = "8",
        mods = "LEADER",
        action = wezterm.action({ ActivateTab = 7 }),
    },
    {
        key = "9",
        mods = "LEADER",
        action = wezterm.action({ ActivateTab = 8 }),
    },
    {
        key = "&",
        mods = "LEADER|SHIFT",
        action = wezterm.action({ CloseCurrentTab = { confirm = true } }),
    },
    {
        key = "d",
        mods = "LEADER",
        action = wezterm.action({ CloseCurrentPane = { confirm = true } }),
    },
    {
        key = "x",
        mods = "LEADER",
        action = wezterm.action({ CloseCurrentPane = { confirm = true } }),
    },
}

-- Maximize window on startup
wezterm.on("gui-startup", function()
    local tab, pane, window = mux.spawn_window({})
    window:gui_window():maximize()
end)

-- Toggle leader (to avoid leader-key tmux congestion)
wezterm.on("toggle-leader", function(window, pane)
    local overrides = window:get_config_overrides() or {}
    if not overrides.leader then
        -- replace it with an "impossible" leader that will never be pressed
        overrides.leader = { key = "_", mods = "CTRL|ALT|SUPER" }
        overrides.colors = { background = "black" }
        -- overrides.colors = { background = "#100000" }
        overrides.window_background_opacity = 1
        wezterm.log_warn("[leader] clear")
    else
        -- restore to the main leader
        overrides.leader = nil
        overrides.colors = nil
        overrides.window_background_opacity = nil
        wezterm.log_warn("[leader] set")
    end
    window:set_config_overrides(overrides)
end)
return config
