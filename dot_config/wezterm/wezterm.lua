-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
local mapping = require("keybinds")

wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.scrollback_lines = 100000

-- Style
config.color_scheme = "Tokyo Night Storm"
config.window_background_opacity = 0.6
config.macos_window_background_blur = 3
config.inactive_pane_hsb = {
  saturation = 0.4,
  brightness = 0.7,
}
----------------------------------------------------
-- Tab
----------------------------------------------------
config.window_decorations = "RESIZE"
config.show_tabs_in_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false

-- Tab bar is transparent
config.window_frame = {
	inactive_titlebar_bg = "none",
	active_titlebar_bg = "none",
}

config.colors = {
	tab_bar = {
		inactive_tab_edge = "none",
	},
}

-- The tab bar color is the same as the background color
config.window_background_gradient = {
	colors = { "#000000" },
}

-- Defined a tab shape
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_upper_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_lower_left_triangle

-- Tab style handler
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = "#5c6d74"
	local foreground = "#FFFFFF"
	local edge_background = "none"

	if tab.is_active then
		background = "#9c7af2"
		foreground = "#FFFFFF"
	end

	local edge_foreground = background
	local title = tab.active_pane.title

	-- Replace string of the part, if tab title is long 
	local function get_last_n_chars(str, n)
		if #str <= n then
			return str
		else
			return "…" .. string.sub(str, -n + 1)
		end
	end

	-- Get a process name
	local function get_process_name(pane)
		local process_name = pane.foreground_process_name

		return process_name:match("([^/]+)$") or ""
	end

	-- Show tab title using a process name
	local function get_custom_title(pane)
		local process_name = get_process_name(pane)

		if process_name ~= "zsh" then
			return process_name
		else
			return get_last_n_chars(title, 23)
		end

		return process_name
	end

	local custom_title = get_custom_title(tab.active_pane)

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = " " .. (tab.tab_index + 1) .. ": " .. custom_title .. " " },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

config.leader = mapping.leader
config.keys = mapping.keys

-- and finally, return the configuration to wezterm
return config
