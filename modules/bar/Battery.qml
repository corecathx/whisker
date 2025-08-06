import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.components
import qs.modules
import qs.preferences
import Quickshell.Services.UPower
Item {
    id: root
    width: 80
    height: 25
    property string remainingTime: "N/A"
    visible: UPower.displayDevice.isLaptopBattery
    property var low_battery_level: 15
    function isLowBattery() {
        return parseFloat(root.battery) < root.low_battery_level;
    }
    property string battery: UPower.displayDevice.isLaptopBattery ? UPower.displayDevice.isLaptopBattery ? (Math.round(UPower.displayDevice.percentage * 1000) / 10)+"%" : "0%" : "0%"
    property int notifiedLevel: -1

    Connections {
        target: UPower.displayDevice
        function onPercentageChanged() {
            if (!UPower.onBattery)
                return;

            const pct = Math.floor(UPower.displayDevice.percentage * 100)

            if (pct === notifiedLevel)
                return;

            if (pct <= 5 && notifiedLevel > 5) {
                notifiedLevel = 5
                Quickshell.execDetached({
                    command: ['notify-send', 'Battery critically low', 'Emergency shutdown imminent unless plugged in.']
                })
            } else if (pct <= low_battery_level && notifiedLevel > low_battery_level) {
                notifiedLevel = low_battery_level
                Quickshell.execDetached({
                    command: ['notify-send', 'Battery very low', 'Please plug in your charger now.']
                })
            } else if (pct <= 20 && notifiedLevel > 20) {
                notifiedLevel = 20
                Quickshell.execDetached({
                    command: ['notify-send', 'Low battery', 'Consider plugging in your charger.']
                })
            }
        }
    }

    property string icon: {
        if (!UPower.onBattery) 
            return "bolt";

        if (UPower.displayDevice.percentage < 0.2)
            return "battery_1_bar"
        else if (UPower.displayDevice.percentage < 0.4)
            return "battery_2_bar"
        else if (UPower.displayDevice.percentage < 0.6)
            return "battery_4_bar"
        else if (UPower.displayDevice.percentage < 0.8)
            return "battery_5_bar"
        else
            return "battery_full"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: clickProc.running = true
    }

    ClippingRectangle {
        id: background
        anchors.fill: parent
        radius: 100
        color: root.isLowBattery() && UPower.onBattery ? "#350000" : Colors.opacify(Colors.background, 0.4)
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
                font.pixelSize: 16
                color: root.isLowBattery() && UPower.onBattery ? "red" : Colors.foreground
            }

            Text {
                id: batteryText
                text: root.battery
                font.pixelSize: 12
                color: root.isLowBattery() && UPower.onBattery ? "red" : Colors.foreground
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
            color: root.isLowBattery() && UPower.onBattery ? "#FF0000" : Colors.foreground

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
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
}
