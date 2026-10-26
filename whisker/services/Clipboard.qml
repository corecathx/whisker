pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property ListModel list: ListModel {}

    property bool fetchListProc: false

    property var imageQueue: []

    IpcHandler {
        target: "cliphist"

        function update() {
            root.fetchListProc = true
        }
    }

    Process {
        id: decodeProc
        property int targetId: -1
        property int targetIndex: -1

        command: ['sh', '-c', `cliphist decode ${targetId} | base64 -w 0`]

        stdout: StdioCollector {
            id: imageDecoder
        }

        onExited: {
            if (exitCode === 0 && targetIndex >= 0 && targetIndex < root.list.count) {
                var base64 = imageDecoder.text.trim()
                var item = root.list.get(targetIndex)
                var mimeType = "image/" + item.binaryType
                root.list.setProperty(targetIndex, "previewSource", "data:" + mimeType + ";base64," + base64)
            } else if (exitCode !== 0) {
                console.error("cliphist decode failed with code:", exitCode)
            }

            processNextImage()
        }
    }

    Process {
        id: fetchListProc
        command: ['cliphist', 'list']
        running: root.fetchListProc

        stdout: StdioCollector {
            onStreamFinished: {
                root.fetchListProc = false
                root.parseClipboardList(this.text)
            }
        }

        onExited: {
            if (exitCode !== 0) {
                console.error("cliphist list failed with code:", exitCode)
            }
        }
    }

    Process {
        id: copyProc
        property int targetId: -1
        command: ['sh', '-c', `cliphist decode ${targetId} | wl-copy`]

        onExited: {
            if (exitCode !== 0) {
                console.error("cliphist decode/copy failed with code:", exitCode)
            }
        }
    }

    Process {
        id: deleteProc
        property int targetId: -1
        command: ['sh', '-c', `echo ${targetId} | cliphist delete`]

        onExited: {
            if (exitCode === 0) {
                root.fetchListProc = true
            } else {
                console.error("cliphist delete failed with code:", exitCode)
            }
        }
    }

    Process {
        id: wipeProc
        command: ['cliphist', 'wipe']

        onExited: {
            if (exitCode === 0) {
                root.list.clear()
            } else {
                console.error("cliphist wipe failed with code:", exitCode)
            }
        }
    }

    function parseClipboardList(text) {
        var lines = text.trim().split('\n')
        var newList = []

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line.length === 0) continue

            var tabIndex = line.indexOf('\t')
            if (tabIndex === -1) continue

            var id = parseInt(line.substring(0, tabIndex))
            var content = line.substring(tabIndex + 1)

            var binaryMatch = content.match(/\[\[ binary data (.+?) ([a-z]+) (.+?) \]\]/)
            var isBinary = binaryMatch !== null

            var entry = {
                id: id,
                content: content,
                isBinary: isBinary,
                binaryType: isBinary ? binaryMatch[2] : "",
                binarySize: isBinary ? binaryMatch[1] : "",
                binaryDimensions: isBinary ? binaryMatch[3] : "",
                previewSource: ""
            }

            newList.push(entry)
        }

        updateList(newList)
    }

    function updateList(newList) {
        for (var i = root.list.count - 1; i >= 0; i--) {
            var found = false
            for (var j = 0; j < newList.length; j++) {
                if (root.list.get(i).id === newList[j].id) {
                    found = true
                    break
                }
            }
            if (!found) {
                root.list.remove(i)
            }
        }

        for (var j = 0; j < newList.length; j++) {
            var exists = false
            var existingIndex = -1
            for (var i = 0; i < root.list.count; i++) {
                if (root.list.get(i).id === newList[j].id) {
                    exists = true
                    existingIndex = i
                    break
                }
            }
            if (!exists) {
                root.list.insert(j, newList[j])
            } else if (existingIndex !== j) {
                root.list.move(existingIndex, j, 1)
            }
        }
    }

    function copyToClipboard(id) {
        copyProc.targetId = id
        copyProc.running = true
    }

    function deleteEntry(id) {
        deleteProc.targetId = id
        deleteProc.running = true
    }

    function loadImagePreview(index) {
        if (index < 0 || index >= root.list.count) return
        var item = root.list.get(index)
        if (!item.isBinary) return
        if (item.previewSource !== "") return

        imageQueue.push({
            id: item.id,
            index: index
        })

        if (!decodeProc.running) {
            processNextImage()
        }
    }

    function processNextImage() {
        if (imageQueue.length === 0) return
        if (decodeProc.running) return

        var next = imageQueue.shift()

        if (next.index >= 0 && next.index < root.list.count) {
            var item = root.list.get(next.index)
            if (item.isBinary && item.previewSource === "") {
                decodeProc.targetId = next.id
                decodeProc.targetIndex = next.index
                decodeProc.running = true
                return
            }
        }

        processNextImage()
    }

    function clearHistory() {
        wipeProc.running = true
    }

    Component.onCompleted: {
        root.fetchListProc = true
    }
}
