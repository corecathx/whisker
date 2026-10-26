
[<< Go back](README.md)

<div align="center">
  <h2>✦ Source Structure ✦</h2>
</div>

A quick look at how Whisker's source is organized.

```
.
├── assets/
├── greetd/
├── integrations/
│   └── hyprland/
├── whisker/
│   ├── components/
│   ├── modules/
│   ├── preferences/
│   ├── services/
│   └── windows/
├── greetd.qml
├── shell.qml
└── welcome.qml
```

<div align="center">
  <h2>✦ Directories ✦</h2>
</div>

- `assets/` contains images, audio, and other resources used by Whisker.
- `greetd/` contains the configuration for Whisker's greeter.
- `integrations/` contains integrations for supported desktop environments and compositors.

<div align="center">
  <h2>✦ Whisker ✦</h2>
</div>

The `whisker/` directory contains the main source code.

- `components/` contains reusable UI components.
- `modules/` contains shared shell modules, including the bar and overlays.
- `preferences/` handles shell preferences.
- `services/` contains services used by the shell.
- `windows/` contains the shell's windows, including the dock, launcher, settings, and quick panel.

<div align="center">
  <h2>✦ Integrations ✦</h2>
</div>

The `integrations/` directory contains compositor-specific configurations.

- `hyprland/` contains Hyprland rules, keybinds, and command definitions.

<div align="center">
  <h2>✦ Entry Points ✦</h2>
</div>

The main QML entry points remain in the root directory.

- `shell.qml` launches the main shell.
- `welcome.qml` handles the welcome screen.
- `greetd.qml` is the greeter entry point.

The reason for this is that `whisker-cli` expects the entry points to be in the root directory.
<sub>(I'll probably change this in the future, who knows?)</sub>
