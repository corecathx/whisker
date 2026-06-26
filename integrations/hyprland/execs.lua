hl.on("hyprland.start", function()
    -- start whisker
    hl.exec_cmd("whisker shell restart")

    -- watch clipboard
    hl.exec_cmd("wl-paste --watch bash -c 'cliphist store && whisker ipc cliphist update'");
end)