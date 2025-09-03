pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.preferences

Singleton {
    Connections {
        target: Preferences
        function onWallpaperChanged(){
            regenColor()
        } 
    }

    function init() {
        console.log('[Theme] Hi.');
    }

    function regenColor() {
        console.log("[Theme] Regenerating Colors...");
        matugenProc.running = true
        console.log("[Theme] Color generation finished.")
    }

    Process {
        id: matugenProc
        command: ["sh", "-c", "~/.config/whisker/scripts/wallpaper.sh " + Preferences.wallpaper]

        stdout: StdioCollector {
            onStreamFinished: console.log("[Theme] ", text.trim())
        }
    }
}
