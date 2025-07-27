pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtQml
import qs.modules

Singleton {
    id: net

    readonly property string icon: ethernetConnected ? "settings_ethernet"
                               : (wifi.enabled ? wifi.icon : "signal_wifi_off")

    property bool ethernetConnected: false

    property QtObject wifi: QtObject {
        id: wifi

        property bool enabled: false
        property string currentName: ""
        property int strength: 0
        property string icon: "signal_wifi_off"

        property var fullList: [] // ex: [{ name: "SSID", strength: 80 }]
        property var list: [] // ssid only

        // strength based sorting
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
            ProcessLauncher.run(["nmcli", "radio", "wifi", enabled ? "off" : "on"])
        }

        function connectTo(ssid) {
            ProcessLauncher.run(["nmcli", "dev", "wifi", "connect", ssid])
        }

        function disconnect() {
            ProcessLauncher.run(["nmcli", "con", "down", "id", currentName])
        }

        function getStrength(ssid) {
            for (let i = 0; i < fullList.length; i++) {
                if (fullList[i].name === ssid)
                    return fullList[i].strength
            }
            return 0
        }

        function refresh() {
            wifiStatus.running = true
            wifiSSID.running = true
            wifiStrength.running = true
            ethStatus.running = true
            wifiScan.running = true
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: wifi.refresh()
    }

    Process {
        id: wifiStatus
        command: ["sh", "-c", "nmcli radio wifi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: wifi.enabled = text.trim() === "enabled"
        }
    }

    Process {
        id: wifiSSID
        command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: wifi.currentName = text.trim()
        }
    }

    Process {
        id: wifiStrength
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^*' | cut -d: -f2"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                wifi.strength = Number(text.trim()) || 0
                wifi.updateIcon()
            }
        }
    }

    Process {
        id: ethStatus
        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE dev | grep 'ethernet:connected'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: ethernetConnected = text.trim() !== ""
        }
    }

    Process {
        id: wifiScan
        command: ["sh", "-c", "nmcli -t -f SSID,SIGNAL dev wifi | grep -v '^--:' | sort -u"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                let parsed = []
                let ssidList = []

                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split(":")
                    if (parts.length >= 2 && parts[0].trim() !== "") {
                        const name = parts[0].trim()
                        const strength = parseInt(parts[1].trim()) || 0
                        parsed.push({ name: name, strength: strength })
                        ssidList.push(name)
                    }
                }

                wifi.fullList = parsed
                wifi.list = ssidList
            }
        }
    }
}
