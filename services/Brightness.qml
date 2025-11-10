pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real value: 0

    property string icon: {
        const icons = ["brightness_empty", "brightness_5", "brightness_6", "brightness_7"];
        if (root.value <= 0) {
            return icons[0];
        } else {
            return icons[Math.min(icons.length - 1, Math.ceil(root.value / (1 / (icons.length - 1))))];
        }
    }

    property int maxValue: 0
    property string filePath: ""
    property bool initialized: false

    signal brightnessChanged(real newValue)

    function init() {
        if (!root.initialized)
            initProcess.running = true
    }

    Process {
        id: initProcess
        command: ["bash", "-c", "echo /sys/class/backlight/*/brightness"]

        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim()
                if (path && path !== "/sys/class/backlight/*/brightness") {
                    root.filePath = path
                    maxProcess.running = true
                } else {
                    console.error("No backlight device found")
                }
            }
        }
    }

    Process {
        id: maxProcess
        command: ["bash", "-c", "cat /sys/class/backlight/*/max_brightness"]

        stdout: StdioCollector {
            onStreamFinished: {
                const max = parseInt(text.trim())
                if (!isNaN(max) && max > 0) {
                    root.maxValue = max
                    root.initialized = true
                    brightnessFile.path = root.filePath
                }
            }
        }
    }

    FileView {
        id: brightnessFile
        path: ""
        watchChanges: true

        function updateValue() {
            reload() // i wanna cry :']
            const normalized = parseInt(text().trim()) / root.maxValue
            if (normalized !== root.value) {
                root.value = normalized
                root.brightnessChanged(normalized)
            }
        }

        onLoaded: updateValue()
        onFileChanged: updateValue()
    }

    function set(v) {
        if (!root.initialized || !root.maxValue)
            return
        const clamped = Math.max(0, Math.min(v, 1))
        const raw = Math.round(clamped * root.maxValue)
        const currentRaw = Math.round(root.value * root.maxValue)

        if (raw === currentRaw) return

        setBnProc.command = ["brightnessctl", "s", raw.toString()]
        setBnProc.running = true

    }

    Process {
        id: setBnProc
    }
}
