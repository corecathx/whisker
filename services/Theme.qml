pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.modules
import qs.preferences

Singleton {
    Connections {
        target: Preferences.theme
        function onWallpaperChanged(){
            regenColor()
        }

        function onSchemeChanged() {
            regenColor()
        }

        function onDarkChanged() {
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
        command: ['matugen', 'image', Preferences.theme.wallpaper, '-m', (Preferences.theme.dark ? 'dark' : 'light'), '-t', "scheme-"+Preferences.theme.scheme]
        //command: ["sh", "-c", "~/.config/whisker/scripts/wallpaper.sh " + Preferences.theme.wallpaper + " " + (Preferences.theme.dark ? 'dark' : 'light') + " " + Preferences.theme.scheme]

        stdout: StdioCollector {
            onStreamFinished: console.log("[ThemeScript] ", text.trim())
        }
    }
}
