import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import qs.modules
import qs.components

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 20
    id: root

    property string icon: "signal_wifi_4_bar"
    property string label: "Wi-Fi"
    property bool hovered: false
    property bool wifiEnabled: true
    property string connectedSSID: ""

    color: !wifiEnabled ? Colors.darken(Colors.accent, hovered ? 0 : 0.1)
                       : Colors.lighten(Colors.accent, hovered ? 0.1 : 0.05)

    Behavior on color {
        ColorAnimation {
            duration: 100
            easing.type: Easing.OutCubic
        }
    }

    RowLayout {
        spacing: 10
        anchors.centerIn: parent

        MaterialSymbol {
            icon: root.icon
            font.pixelSize: 24
            color: Colors.foreground
        }

        Text {
            text: root.label
            font.pixelSize: 16
            color: Colors.foreground
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: {
            toggleProc.command = ["sh", "-c", wifiEnabled
                ? "nmcli radio wifi off"
                : "nmcli radio wifi on"];
            toggleProc.running = true;
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            statusProc.running = true
            ssidProc.running = true
        }
    }

    Process {
        id: statusProc
        running: true
        command: ["sh", "-c", "nmcli radio wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                wifiEnabled = text.trim() === "enabled"
            }
        }
    }

    Process {
        id: ssidProc
        command: ["sh", "-c",
            "nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d: -f2"
        ]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const ssid = text.trim()
                connectedSSID = ssid.length > 15 ? ssid.slice(0, 15) + "..." : ssid

                if (!wifiEnabled) {
                    icon = "signal_wifi_off"
                    label = "Wi-Fi"
                } else {
                    icon = "signal_wifi_4_bar"
                    label = connectedSSID !== "" ? connectedSSID : "Wi-Fi"
                }
            }
        }
    }

    Process {
        id: toggleProc
        stdout: StdioCollector {
            onStreamFinished: {
                QTimer.singleShot(500, () => {
                    statusProc.running = true
                    ssidProc.running = true
                })
            }
        }
    }
}
