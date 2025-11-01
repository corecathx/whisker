//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma UseQApplication
import QtQuick
import Quickshell
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
import qs.services

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
        active: false

        StatsWindow {}
    }

    // EmojiWindow {}

    // Whisker Apps.
    Launcher {}

    Component.onCompleted: {
        Theme.init()
        Audio.init()
    }
    // DevWindow {}
    //
    Screencapture {}
    PolkitPrompt {}

}
