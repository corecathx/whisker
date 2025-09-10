pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.preferences

Singleton {
    Connections {
        target: Preferences
        property bool ignoreFirstWp: true
        property bool ignoreFirstCs: true
        property bool ignoreFirstDm: true
        function onWallpaperChanged(){
            if (ignoreFirstWp) {
                ignoreFirstWp = false
                console.log("[Theme] Ignoring first wallpaper change signal.")
                return
            }
            regenColor()
        } 

        function onColorSchemeChanged() {
            if (ignoreFirstCs) {
                ignoreFirstCs = false
                console.log("[Theme] Ignoring first color scheme change signal.")
                return
            }
            regenColor()
        }
        
        function onDarkModeChanged() {
            // if (ignoreFirstDm) {
            //     ignoreFirstDm = false
            //     console.log("[Theme] Ignoring first dark mode change signal.")
            //     return
            // }
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
        command: ["sh", "-c", "~/.config/whisker/scripts/wallpaper.sh " + Preferences.wallpaper + " " + (Preferences.darkMode ? 'dark' : 'light') + " " + Preferences.colorScheme]

        stdout: StdioCollector {
            onStreamFinished: console.log("[Theme] ", text.trim())
        }
    }
}
