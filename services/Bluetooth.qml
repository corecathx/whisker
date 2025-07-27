pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtQml
import qs.modules

Singleton {
    property bool enabled: false
    property bool connected: false
    property string connectedName: ""

    property string icon: "bluetooth_disabled"
    property string label: "Bluetooth"

    property var pairedDevices: [] // [{ name, mac }]
    property var availableDevices: [] // [{ name, mac }]
    property var fullList: [] // all scanned

    function updateIcon() {
        if (!enabled) {
            icon = "bluetooth_disabled"
            label = "Bluetooth"
        } else if (connected) {
            icon = "bluetooth_connected"
            label = connectedName !== "" ? connectedName : "Bluetooth"
        } else {
            icon = "bluetooth_searching"
            label = "Bluetooth"
        }
    }

    function toggle() {
        Quickshell.execDetached({
            command: enabled
                ? ["bluetoothctl", "power", "off"]
                : ["bluetoothctl", "power", "on"]
        })
    }


    function connect(mac) {
        Quickshell.execDetached({
            command: ["bluetoothctl", "connect", mac]
        })
    }

    function disconnect(mac) {
        Quickshell.execDetached({
            command: ["bluetoothctl", "disconnect", mac]
        })
    }

    function pair(mac) {
        Quickshell.execDetached({
            command: ["bluetoothctl", "pair", mac]
        })
    }

    function remove(mac) {
        Quickshell.execDetached({
            command: ["bluetoothctl", "remove", mac]
        })
    }

    function refresh() {
        btStatus.running = true
        btDevices.running = true
        btConnected.running = true
    }

    Timer {
        interval: 4000
        running: true
        repeat: true
        onTriggered: refresh()
    }

    Process {
        id: btStatus
        command: ["sh", "-c", "bluetoothctl show | grep 'Powered:' | awk '{print $2}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                enabled = text.trim() === "yes"
                updateIcon()
            }
        }
    }

    Process {
        id: btConnected
        command: ["sh", "-c", "bluetoothctl info | grep Name | awk '{print substr($0, index($0,$2))}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const name = text.trim()
                connected = name !== ""
                connectedName = name
                updateIcon()
            }
        }
    }

    Process {
        id: btDevices
        command: ["sh", "-c", "bluetoothctl devices"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                let paired = []
                let all = []

                for (let i = 0; i < lines.length; i++) {
                    const match = lines[i].match(/^Device ([0-9A-F:]+) (.+)$/)
                    if (match) {
                        const mac = match[1]
                        const name = match[2]
                        all.push({ name: name, mac: mac })
                        paired.push({ name: name, mac: mac })
                    }
                }

                pairedDevices = paired
                fullList = all
                availableDevices = all
            }
        }
    }
}
