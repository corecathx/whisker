----------------------
---- Window rules ----
----------------------

hl.window_rule({
    match = {
        title = "^(Whisker Settings)(.*)$",
    },
    float = true,
    center = true,
})

hl.window_rule({
    match = {
        title = "^(Whisker Setup)(.*)$",
    },
    float = true,
    center = true,
})

---------------------
---- Layer rules ----
---------------------

hl.layer_rule({
    match = {
        namespace = "whisker:osdpanel",
    },
    no_anim = true,
})

hl.layer_rule({
    match = {
        namespace = "whisker:popout",
    },
    no_anim = true,
})

hl.layer_rule({
    match = {
        namespace = "whisker:screencapture",
    },
    no_anim = true,
})

hl.layer_rule({
    match = {
        namespace = "whisker:wallpaper",
    },
    no_anim = true,
})

hl.layer_rule({
    match = {
        namespace = "whisker:prompt",
    },
    no_anim = true,
})

hl.layer_rule({
    match = {
        namespace = "whisker:bar",
    },
    no_anim = true,
})