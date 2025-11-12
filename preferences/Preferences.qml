pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules

Singleton {
    id: root

    signal reloaded

    // internal
    property bool ready: false
    property bool spawnedWelcome: false

    // configuration
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
    }

    property QtObject misc: QtObject {
        property bool cavaEnabled: true
        property bool notificationEnabled: true
        property bool renderOverviewWindows: true
        property bool finishedSetup: false
        property string githubUsername: ""
        property bool translateLyrics: true
        property string lyricsLanguage: 'en'
    }

    onReloaded: {
        if (!root.misc.finishedSetup && !root.spawnedWelcome) {
            console.log("what");
            root.spawnedWelcome = true;
            Quickshell.execDetached({
                command: ["whisker", "welcome"]
            });
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
        stdout: StdioCollector {
            onStreamFinished: fileView.reload()
        }
    }

    function load(content) {
        const parsed = JSON.parse(content);

        for (const [name, value] of Object.entries(parsed)) {
            if (root.hasOwnProperty(name)) {
                if (typeof root[name] === "object" && value !== null)
                    for (const [key, val] of Object.entries(value))
                        root[name][key] = val;
                else
                    root[name] = value;
            }
        }

        root.ready = true;
        root.reloaded();
    }

    FileView {
        id: fileView
        path: Utils.getConfigRelativePath("preferences.json")
        watchChanges: true

        onFileChanged: {
            console.log("Preferences updated.");
            fileView.reload();
        }

        onLoaded: root.load(text())
    }

    function horizontalBar() {
        return root.bar.position === "top" || root.bar.position === "bottom";
    }

    function verticalBar() {
        return root.bar.position === "left" || root.bar.position === "right";
    }
}
