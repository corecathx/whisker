//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma UseQApplication
//@ pragma DefaultEnv QS_DROP_EXPENSIVE_FONTS=1
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import QtQuick
import Quickshell

import qs.whisker.preferences
import qs.whisker.services

import qs.whisker.modules.bar
import qs.whisker.modules.corners
import qs.whisker.modules.overlays

import qs.whisker.windows.wallpaper
import qs.whisker.windows.overlays
import qs.whisker.windows.dock
import qs.whisker.windows.quickpanel
import qs.whisker.windows.quickpanel.right
import qs.whisker.windows.notification
import qs.whisker.windows.osdpanel

import qs.whisker.windows.launcher
import qs.whisker.windows.settings
import qs.whisker.windows.lockscreen
import qs.whisker.windows.emojies
import qs.whisker.windows.screencapture
import qs.whisker.windows.cliphist
import qs.whisker.windows.keybinds
import qs.whisker.windows.stats
import qs.whisker.windows.dev

import qs.whisker.windows.firsttime
import qs.whisker.windows.polkit
import qs.whisker.windows.power

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
        Whisker.init();

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