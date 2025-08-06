pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtQml
import qs.preferences

Singleton {
    id: net

    property bool ethernetConnected: false

    readonly property string icon: ethernetConnected ? "settings_ethernet"
                               : (wifi.enabled ? wifi.icon : "signal_wifi_off")

    property QtObject wifi: QtObject {
        id: wifi

        property bool enabled: false
        property string currentName: ""
        property int strength: 0
        property string icon: "signal_wifi_off"

        property var fullList: []
        property var list: []
        property var knownList: []

        readonly property var sortedList: fullList.slice().sort((a, b) => b.strength - a.strength)

        function updateIcon() {
            if (!enabled) {
                icon = "signal_wifi_off"
                return
            }

            if (strength >= 75) icon = "signal_wifi_4_bar"
            else if (strength >= 50) icon = "network_wifi_3_bar"
            else if (strength >= 25) icon = "network_wifi_2_bar"
            else if (strength > 0)  icon = "network_wifi_1_bar"
            else icon = "signal_wifi_0_bar"
        }

        function toggle() {
            Quickshell.execDetached({
                command: ["nmcli", "radio", "wifi", enabled ? "off" : "on"]
            })
        }

        function isSecured(ssid) {
            return fullList.find(e => e.name === ssid)?.secured ?? false
        }

        function isKnown(ssid) {
            return knownList.includes(ssid)
        }

        function connectTo(ssid, password = "") {
            if (isSecured(ssid) && password === "")
                return console.log("Password required for secured network")

            let cmd = ["nmcli", "dev", "wifi", "connect", ssid]
            if (password) cmd.push("password", password)
            Quickshell.execDetached({ command: cmd })
        }

        function disconnect() {
            Quickshell.execDetached({
                command: ["nmcli", "con", "down", "id", currentName]
            })
        }

        function refresh() {
            wifiFetch.running = true
            knownFetch.running = true
            ethernetFetch.running = true
        }
    }

    Process {
        id: wifiFetch
        command: ["sh", "-c", "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n")
                let list = []
                let ssids = []
                let current = ""
                let signal = 0

                for (let line of lines) {
                    let [inUse, name, strength, sec] = line.split(":")
                    if (!name || name === "--") continue
                    let entry = {
                        name,
                        strength: parseInt(strength) || 0,
                        secured: sec !== ""
                    }
                    if (inUse === "*") {
                        wifi.currentName = name
                        wifi.strength = entry.strength
                        current = name
                        signal = entry.strength
                    }
                    list.push(entry)
                    ssids.push(name)
                }

                wifi.fullList = list
                wifi.list = ssids
                wifi.updateIcon()

                wifiStatus.running = true
            }
        }
    }

    Process {
        id: wifiStatus
        command: ["nmcli", "radio", "wifi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: wifi.enabled = text.trim() === "enabled"
        }
    }

    Process {
        id: knownFetch
        command: ["sh", "-c", "nmcli -t -f NAME connection show"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: wifi.knownList = text.trim().split("\n").filter(Boolean)
        }
    }

    Process {
        id: ethernetFetch
        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE dev | grep 'ethernet:connected'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: ethernetConnected = text.trim() !== ""
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: wifi.refresh()
    }
}
