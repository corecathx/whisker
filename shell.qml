import "modules/bar/"
import qs.modules.overlays
import "modules/corners/"
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
import qs.services

ShellRoot {
    Wallpaper {}
    ScreenCorners{}
    VolumeOSD {}
    Bar {}
    QuickPanel {}
    Notification {}
    Settings {}
    Launcher {}

    Lockscreen {}
}
