//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma UseQApplication
import QtQuick
import Quickshell
import qs.modules.overlays
import qs.modules.bar
import qs.modules.corners
import qs.windows.wallpaper
import qs.windows.quickpanel
import qs.windows.settings
import qs.windows.notification
import qs.windows.launcher
import qs.windows.lockscreen
import qs.windows.emojies
import qs.windows.screencapture
import qs.windows.dev
import qs.windows.osdpanel
import qs.windows.firsttime
import qs.windows.polkit
import qs.windows.power
import qs.windows.cliphist
import qs.services
import qs.windows.stats
import qs.windows.overlays
import qs.windows.keybinds
import qs.preferences

ShellRoot {
    // Shell-specific windows.
    Wallpaper {}
    ScreenCorners {}
    OsdPanel {}
    Bar {}
    QuickPanel {}
    Notification {}
    Settings {}
    Lockscreen {}

    LazyLoader {
        active: Preferences.misc.showStatsOverlay

        StatsOverlay {}
    }

    // EmojiWindow {}

    // Whisker Apps.
    Launcher {}

    Component.onCompleted: {
        Theme.init();
        Audio.init();
        Brightness.init();
        Lrclib.fetchLyrics();
    }
    // DevWindow {}
    //
    Screencapture {}
    PolkitPrompt {}
    PowerPrompt {}
    Cliphist {}

    OverlayWrapper {}

    KeybindsListWindow {}
}
