//@ pragma Env QT_SCALE_FACTOR=1
import "modules/bar/"
import qs.modules.overlays
import "modules/corners/"
import QtQuick
import QtQuick.Effects
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
import qs.windows.dev
import qs.windows.osdpanel
import qs.services

ShellRoot {
    Wallpaper {}
    ScreenCorners {}
    //VolumeOSD {}
    OsdPanel {}
    Bar {}
    QuickPanel {}
    Notification {}
    Settings {}
    Launcher {}
    Lockscreen {}

    LazyLoader {
        active: false

        StatsWindow {}
    }

    // EmojiWindow {}

    Component.onCompleted: {
        Theme.init()
        Audio.init()
    }
    // DevWindow {}
}
