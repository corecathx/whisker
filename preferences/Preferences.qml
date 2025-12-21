pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules

Singleton {
    id: root
    signal reloaded

    property bool ready: false
    property bool spawnedWelcome: false

    property QtObject bar: QtObject {
        property string position: "top"
        property bool small: false
        property int padding: 200
        property bool autoHide: false
        property bool keepOpaque: true
    }

    property QtObject theme: QtObject {
        property bool dark: true
        property string scheme: "tonal-spot"
        property bool useWallpaper: true
        property string wallpaper: ""
        property real contrast: 0.0
    }

    property QtObject misc: QtObject {
        property bool cavaEnabled: true
        property bool notificationEnabled: true
        property bool renderOverviewWindows: true
        property bool finishedSetup: false
        property string githubUsername: ""
        property bool translateLyrics: true
        property string lyricsLanguage: 'en'
        property bool showStatsOverlay: false
        property bool activateLinuxOverlay: false
        property int clickerCount: 0
    }

    property QtObject widgets: QtObject {
        property bool showLyrics: true
        property bool lyricsAsOverlay: false

        property QtObject desktop: QtObject {
            property bool clock: true
            property bool player: false
        }
    }

    onReloaded: {
        if (!root.misc.finishedSetup && !root.spawnedWelcome) {
            root.spawnedWelcome = true;
            Quickshell.execDetached({ command: ["whisker", "welcome"] });
        }
    }

    Component.onCompleted: {
        fileView.reload();
        root.ready = true;
    }

    Process {
        id: exitProc
        command: ["whisker", "prefs", "--no-prompt"]
        running: true
        stdout: StdioCollector { onStreamFinished: fileView.reload() }
    }

    function loadNested(target, obj) {
        for (const [key, value] of Object.entries(obj)) {
            if (!target.hasOwnProperty(key)) continue;

            if (typeof value === "object" && value !== null && !Array.isArray(value)) {
                if (typeof target[key] === "object" && target[key] !== null) {
                    loadNested(target[key], value);
                }
            } else {
                target[key] = value;
            }
        }
    }

    function load(content) {
        const parsed = JSON.parse(content);
        loadNested(root, parsed);
        root.ready = true;
        root.reloaded();
    }

    FileView {
        id: fileView
        path: Utils.getConfigRelativePath("preferences.json")
        watchChanges: true
        onFileChanged: {
            // console.log("Preferences updated.");
            fileView.reload();
        }
        onLoaded: root.load(text())
    }

    function horizontalBar() { return root.bar.position === "top" || root.bar.position === "bottom"; }
    function verticalBar() { return root.bar.position === "left" || root.bar.position === "right"; }
}
