pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules

Singleton {
    id: root
    readonly property PersistentProperties persist: PersistentProperties {
        reloadableId: "whisker-service"
        property bool fetched: false
    }
    property string version: 'unknown'
    property string commit: 'unknown'
    property var updates: [] 

    function updateInfo() {
        Log.info("services/Whisker.qml", "refetching whisker info!");
        infoFetch.running = true
    }

    Process {
        id: infoFetch
        command: ["whisker", "version", "--json"]

        stdout: StdioCollector {
            id: infoOutput

            onStreamFinished: {
                Log.info("services/Whisker.qml", 'got whisker info!!')
                try {
                    const info = JSON.parse(text)

                    root.version = info.version ?? "unknown"
                    root.commit = info.commit ?? "unknown"
                    root.updates = Array.isArray(info.updates) ? info.updates : []
                    Log.info("services/Whisker.qml", "whisker info updated!!")
                } catch (error) {
                    Log.warn("services/Whisker.qml", "failed to parse Whisker version info: " + error)
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                Log.warn("services/Whisker.qml", "whisker version --json exited with code " + exitCode)
        }
    }

    function init() {
        if (persist.fetched) {
            Log.info('services/Whisker.qml', "whisker info was previously fetched from old session, ignoring init.")
            return;
        }
        persist.fetched = true
        updateInfo();
    }

    //// public functions ////

    function notify(title, body) {
        Quickshell.execDetached({
            command: ["whisker", "notify", title, body]
        });
    }
    
    function setPrefs(key, value) {
        Log.info('services/Whisker.qml', 'setting preferences "' + key + '" to "' + value + '"');
        Quickshell.execDetached({
            command: ['whisker', 'prefs', 'set', key, value]
        })
    }
}