import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.components
import qs.modules

Item {
    id: root
    width: 80
    height: 25

    property var low_battery_level: 15
    function isLowBattery() {
        return parseFloat(root.battery) < root.low_battery_level;
    }
    property string battery: "0%"
    property string icon: "bolt"

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: clickProc.running = true
    }

    ClippingRectangle {
        id: background
        anchors.fill: parent
        radius: 100
        color: root.isLowBattery() ? "#350000" : "transparent"
        /*border {
            width: 1
            color: 'white'
        }*/
        RowLayout {
            id: textLayer
            anchors.centerIn: parent
            spacing: 4

            MaterialSymbol {
                icon: "bolt"
                visible: root.icon === "bolt"
                font.pixelSize: 18
                color: root.isLowBattery() ? "red" : Colors.foreground
            }

            Text {
                id: batteryText
                text: root.battery
                font.pixelSize: 12
                color: root.isLowBattery() ? "red" : Colors.foreground
                font {
                    bold: root.isLowBattery()
                }
            }
        }

        Rectangle {
            id: bar
            clip: true
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: root.width * Math.min(Math.max(parseFloat(battery), 0), 100) / 100
            color: parseFloat(battery) < root.low_battery_level ? "#FF0000" : Colors.foreground

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            RowLayout {
                id: textLayer2
                x: (root.width - width) / 2
                y: (root.height - height) / 2
                spacing: 4

                MaterialSymbol {
                    icon: "bolt"
                    visible: root.icon === "bolt"
                    font.pixelSize: 16
                    color: "black"
                }

                Text {
                    text: root.battery
                    font.pixelSize: 12
                    color: "black"
                }
            }
        }
    }

    Process {
        id: batteryProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/battery.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.battery = this.text.trim()
        }
    }

    Process {
        id: iconProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/battery.sh icon"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.icon = this.text.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: batteryProc.running = true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: iconProc.running = true
    }

    Process {
        id: clickProc
        command: ["sh", "-c", "notify-send 'wawa battery " + battery + "'"]
    }
}
