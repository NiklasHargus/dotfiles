-- Hyprland Lua config, converted from hyprland.conf
-- Refer to the wiki: https://wiki.hypr.land/Configuring/Start/


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1200@60",
    position = "auto",
    scale    = 1,
})

-- hl.monitor({ output = "DP-4", mode = "1920x1080@120", position = "auto", scale = 1 })
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal    = "kitty"
-- local terminal    = "ghostty"
local fileManager = "nautilus"
local menu        = "rofi -show drun"
local lock        = "hyprlock"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("dunst")
    -- hl.exec_cmd("eww open bar")
    hl.exec_cmd("qs -d")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- GTK theming (formerly plain `exec =` lines)
    hl.exec_cmd([[gsettings set org.gnome.desktop.interface gtk-theme "adwaita-dark"]])
    hl.exec_cmd([[gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"]])
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE", "24")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in     = 2,
        gaps_out    = 2,
        border_size = 2,

        col = {
            active_border   = "rgba(205,214,244,0.7)",
            inactive_border = "rgba(595959aa)",
        },

        layout = "dwindle",

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,
    },

    decoration = {
        rounding = 5,

        blur = {
            enabled           = true,
            size              = 10,
            passes            = 2,
            new_optimizations = true,
            ignore_opacity    = true,
            xray              = false,
            popups            = true,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {1.0, 1.05} } })

hl.animation({ leaf = "windows",     enabled = true, speed = 2, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6, bezier = "default" })
-- Quickshell animates its own popups; a compositor fade on top causes ghosting.
hl.animation({ leaf = "fadePopups",  enabled = false })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})


----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0,    -- Set to 0 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "altgr-intl",
        kb_model   = "",
        kb_options = "caps:escape",
        kb_rules   = "",

        follow_mouse = 2,

        sensitivity   = 0.1, -- -1.0 - 1.0, 0 means no modification.
        accel_profile = "flat",

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

hl.config({
    gestures = {
        workspace_swipe_create_new = true,
        workspace_swipe_distance    = 500,
    },
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "ALT"

hl.bind(mainMod .. " + T",      hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
hl.bind(mainMod .. " + M",      hl.dsp.exit())
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + S",      hl.dsp.window.pin())
hl.bind(mainMod .. " + R",      hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P",      hl.dsp.window.pseudo())               -- dwindle
hl.bind(mainMod .. " + Tab",    hl.dsp.layout("togglesplit"))         -- dwindle
hl.bind(mainMod .. " + F",      hl.dsp.exec_cmd("zen-browser"))
hl.bind(mainMod .. " + return", hl.dsp.window.fullscreen())

-- EWW BAR
-- hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("~/scripts/toggle_eww.sh"))
-- QUICKSHELL BAR
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("qs ipc call bar toggle"))

-- Move focus with mainMod + hjkl
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))

-- Move window within workspace
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Resize active window with SHIFT + mainMod + arrow keys
hl.bind("SHIFT + " .. mainMod .. " + left",  hl.dsp.window.resize({ x = -10, y = 0 }))
hl.bind("SHIFT + " .. mainMod .. " + right", hl.dsp.window.resize({ x = 10,  y = 0 }))
hl.bind("SHIFT + " .. mainMod .. " + up",    hl.dsp.window.resize({ x = 0,   y = -10 }))
hl.bind("SHIFT + " .. mainMod .. " + down",  hl.dsp.window.resize({ x = 0,   y = 10 }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Special keys
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("amixer set 'Master' 5%+"))
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("amixer set 'Master' 5%-"))
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("amixer set 'Master' 0%"))

-- Lock
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd(lock))

-- Lock on lid close is handled by hypridle's before_sleep_cmd, so the lock
-- is up before suspend (a lid bind races logind and flashes the desktop on resume).
-- hl.bind("switch:Lid Switch", hl.dsp.exec_cmd(lock))


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Blur the Eww bar (disabled).
-- hl.layer_rule({
--     name  = "blur-gtk-layer-shell",
--     match = { namespace = "^(gtk-layer-shell)$" },
--     blur        = true,
--     blur_popups = true,
-- })

-- Blur the translucent Quickshell bar.
hl.layer_rule({
    name  = "blur-quickshell-bar",
    match = { namespace = "^(quickshell-bar)$" },
    blur        = true,
    blur_popups = true,
    -- Only blur pixels that are actually drawn, not the transparent part of
    -- the control center while it's still extending.
    ignore_alpha = 0.1,
})

hl.window_rule({
    name  = "tile-matlab",
    match = { title = "^(MATLAB R2023b - academic use)$" },
    tile  = true,
})

hl.window_rule({
    name  = "float-blueman",
    match = { title = "^(blueman-manager)$" },
    float = true,
})

hl.window_rule({
    name  = "float-localsend",
    match = { class = "^(localsend)$" },
    float = true,
    size  = "1000 1000",
})
