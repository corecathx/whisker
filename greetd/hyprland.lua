hl.on("hyprland.start", function()
    hl.exec_cmd("sh -c 'qs -p /usr/share/whisker/greetd.qml; hyprctl dispatch \"hl.dsp.exit()\"'")
    -- hl.exec_cmd("kitty")
end)

-- hl.bind("SUPER + T", hl.dsp.exec_cmd('kitty'))

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.config({
    animations = {
        enabled = false
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0
    }
})