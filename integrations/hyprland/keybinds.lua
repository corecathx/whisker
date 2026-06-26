--- Whisker keybinds. ---

-- Launcher
hl.bind("SUPER + SUPER_L", hl.dsp.global("whisker:launcher"), { release = true })

-- Quick panel
hl.bind("SUPER + A", hl.dsp.global("whisker:quickpanel"), { release = true })

-- Settings
hl.bind("SUPER + I", hl.dsp.global("whisker:settings"), { release = true })

-- Lock screen
hl.bind("SUPER + L", hl.dsp.global("whisker:lock"))

-- Screenshot (region)
hl.bind("SUPER + SHIFT + S", hl.dsp.global("whisker:screenshot"), { release = true })

-- Clipboard
hl.bind("SUPER + V", hl.dsp.global("whisker:clipboard"))
