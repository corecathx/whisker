pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.modules
import qs.preferences

Singleton {
    Connections {
        target: Preferences
        function onWallpaperChanged(){
            regenColor()
        }

        function onColorSchemeChanged() {
            regenColor()
        }

        function onDarkModeChanged() {
            regenColor()
        }
    }

    function init() {
        console.log('[Theme] Hi.');
    }

    function regenColor() {
        console.log("[Theme] Regenerating Colors...");
        matugenProc.running = true
        Appearance.reloadScheme("")
        console.log("[Theme] Color generation finished.")
    }

    Process {
        id: matugenProc
        command: ['matugen', 'image', Preferences.wallpaper, '-m', (Preferences.darkMode ? 'dark' : 'light'), '-t', "scheme-"+Preferences.colorScheme]
        //command: ["sh", "-c", "~/.config/whisker/scripts/wallpaper.sh " + Preferences.wallpaper + " " + (Preferences.darkMode ? 'dark' : 'light') + " " + Preferences.colorScheme]

        stdout: StdioCollector {
            onStreamFinished: console.log("[ThemeScript] ", text.trim())
        }
    }
}
