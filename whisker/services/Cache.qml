pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.whisker.modules

Singleton {
    id: root

    signal loaded
    signal flushed

    property bool ready: false
    property var entries: ({
        lyrics: [],
        wallpapers: [],
        githubCompare: ({
            fetchedAt: 0,
            updates: []
        })
    })
    property var files: ({})
    property var loadedFiles: ({})

    readonly property string cacheDir: {
        var path = Utils.getCachePath("")
        return path.substring(0, path.lastIndexOf("/"))
    }

    Process {
        id: mkdirProc
        command: ["mkdir", "-p", root.cacheDir]
        running: true

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                Log.warn("services/Cache.qml", "Failed to create cache directory")
                return
            }

            for (const name of Object.keys(root.entries))
                root.register(name, root.entries[name])
        }
    }

    Component {
        id: fileComponent

        FileView {
            required property string cacheName
            path: Utils.getCachePath(cacheName + ".json")
            atomicWrites: true

            onLoaded: root.loadEntry(cacheName, text())
            onLoadFailed: root.initializeEntry(cacheName)
        }
    }

    function register(name, initialValue = []) {
        if (files[name]) return

        if (!Object.prototype.hasOwnProperty.call(entries, name))
            entries = Object.assign({}, entries, { [name]: initialValue })

        loadedFiles[name] = false
        files[name] = fileComponent.createObject(root, {
            cacheName: name
        })
    }

    function initializeEntry(name) {
        Log.info("services/Cache.qml", "Creating " + name + ".json")
        files[name].setText(JSON.stringify(entries[name], null, 2))
        loadedFiles[name] = true
        checkReady()
    }

    function loadEntry(name, content) {
        try {
            entries = Object.assign({}, entries, {
                [name]: JSON.parse(content)
            })
        } catch (e) {
            Log.warn("services/Cache.qml", "Failed to parse " + name + ".json: " + e)
            files[name].setText(JSON.stringify(entries[name], null, 2))
        }

        loadedFiles[name] = true
        checkReady()
    }

    function checkReady() {
        for (const name of Object.keys(files)) {
            if (!loadedFiles[name]) return
        }

        if (ready) return

        ready = true
        Log.info("services/Cache.qml", "Ready")
        loaded()
    }

    function flush(name = "") {
        const names = name ? [name] : Object.keys(files)

        for (const key of names) {
            if (!files[key]) {
                Log.warn("services/Cache.qml", "Unknown cache: " + key)
                continue
            }

            files[key].setText(JSON.stringify(entries[key], null, 2))
        }

        flushed()
    }
}