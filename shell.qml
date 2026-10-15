//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma UseQApplication
//@ pragma DefaultEnv QS_DROP_EXPENSIVE_FONTS=1
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import QtQuick
import Quickshell

import qs.preferences
import qs.services

import qs.modules.bar
import qs.modules.corners
import qs.modules.overlays

import qs.windows.wallpaper
import qs.windows.overlays
import qs.windows.dock
import qs.windows.quickpanel
import qs.windows.quickpanel.right
import qs.windows.notification
import qs.windows.osdpanel

import qs.windows.launcher
import qs.windows.settings
import qs.windows.lockscreen
import qs.windows.emojies
import qs.windows.screencapture
import qs.windows.cliphist
import qs.windows.keybinds
import qs.windows.stats
import qs.windows.dev

import qs.windows.firsttime
import qs.windows.polkit
import qs.windows.power

ShellRoot {
    id: root

    function getEnvSafe(env) {
        return Quickshell.env(env) ?? ""
    }

    readonly property bool debug: getEnvSafe("QSG_VISUALIZE") !== ""

    Wallpaper {}

    LazyLoader {
        active: !root.debug;
        ScreenCorners {}
    }

    Bar {}
    Dock {}

    QuickPanel {}
    RightPanel {}

    NotificationWindow {}
    OsdPanel {}

    LazyLoader {
        active: Preferences.misc.showStatsOverlay
        StatsOverlay {}
    }

    // Whisker Apps.
    Launcher {}
    Settings {}
    Lockscreen {}

    EmojiWindow {}

    Screencapture {}
    Cliphist {}

    OverlayWrapper {}

    KeybindsListWindow {}

    PolkitPrompt {}
    PowerPrompt {}

    // DevWindow {}

    // PersistentProperties {
        // id: persist
        // reloadableId: "persistedStates"

        // property bool reloaded: false
    // }

    Component.onCompleted: {
        console.log("isDebug: " + debug);
        Theme.init();
        Audio.init();
        Brightness.init();
        Lrclib.fetchLyrics();

        // if (!persist.reloaded) {
            // persist.reloaded = true;
            // Quickshell.reload(false);
        // }
        // else
            // Log.info('Whisker', 'reloaded!!!!');
        // Whisker.init()
        // Plugins.init()
    }
}