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

    property string icon: "bluetooth"
    property string label: "Bluetooth"
    property bool hovered: false
    property bool bluetoothEnabled: true
    property string connectedDevice: ""

    color: !bluetoothEnabled
        ? Colors.darken(Colors.accent, hovered ? 0 : 0.1)
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
            toggleProc.command = ["sh", "-c", bluetoothEnabled
                ? "echo -e 'power off\\nquit' | bluetoothctl"
                : "echo -e 'power on\\nquit' | bluetoothctl"];
            toggleProc.running = true;
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            statusProc.running = true
            deviceProc.running = true
        }
    }

    Process {
        id: statusProc
        command: ["sh", "-c", "bluetoothctl show | grep 'Powered:'"]
        running:true
        stdout: StdioCollector {
            onStreamFinished: {
                const powered = text.trim().split(":")[1].trim()
                bluetoothEnabled = (powered === "yes")
            }
        }
    }
    Process {
        id: deviceProc
        command: ["sh", "-c",
            "ADDR=$(bluetoothctl devices Connected | awk '{print $2}' | head -n1); " +
            "[ -n \"$ADDR\" ] && bluetoothctl info \"$ADDR\" | grep 'Name:' || echo ''"
        ]
        running:true
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.trim()
                if (line.startsWith("Name:")) {
                    let name = line.split(":").slice(1).join(":").trim()
                    connectedDevice = name.length > 10 ? name.slice(0, 10) + "..." : name
                } else {
                    connectedDevice = ""
                }

                if (!bluetoothEnabled) {
                    icon = "bluetooth_disabled"
                    label = "Bluetooth"
                } else {
                    icon = "bluetooth"
                    label = connectedDevice !== "" ? connectedDevice : "Bluetooth"
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
                    deviceProc.running = true
                })
            }
        }
    }
}
