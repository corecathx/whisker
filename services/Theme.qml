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
        if (Utils.isVideo(Preferences.theme.wallpaper)) { // use whisker's color gen if it's a video.
            matugenProc.command = ['whisker', 'wallpaper', Preferences.theme.wallpaper, '--no-scheme-gen']
        } else {
            matugenProc.command = ['matugen', 'image', Preferences.theme.wallpaper, '-m', (Preferences.theme.dark ? 'dark' : 'light'), '-t', "scheme-"+Preferences.theme.scheme]
        }
        matugenProc.running = true
        Appearance.reloadScheme("")
        console.log("[Theme] Color generation finished.")
    }

    Process {
        id: matugenProc
        //command: ["sh", "-c", "~/.config/whisker/scripts/wallpaper.sh " + Preferences.theme.wallpaper + " " + (Preferences.theme.dark ? 'dark' : 'light') + " " + Preferences.theme.scheme]

        stdout: StdioCollector {
            onStreamFinished: console.log("[ThemeScript] ", text.trim())
        }
    }
}
