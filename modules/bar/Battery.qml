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
    visible: UPower.displayDevice.isLaptopBattery

    property var low_battery_level: 15
    property int notifiedLevel: -1
    property string battery: UPower.displayDevice.isLaptopBattery 
        ? (Math.round(UPower.displayDevice.percentage * 1000) / 10) + "%" 
        : "0%"

    // Battery color based on state
    property color batteryColor: {
        if (!UPower.onBattery) {
            return Appearance.colors.m3primary;  // Charging → primary
        }
        if (UPower.displayDevice.percentage < 0.2) {
            return Appearance.colors.m3error;    // Low battery → error
        }
        if (UPower.displayDevice.percentage < 0.5) {
            return Appearance.colors.m3secondary; // Medium → secondary
        }
        return Appearance.colors.m3primary;       // Healthy → primary
    }

    function isLowBattery() {
        return parseFloat(root.battery) < root.low_battery_level;
    }

    // Notifications for battery levels
    Connections {
        target: UPower.displayDevice
        function onPercentageChanged() {
            if (!UPower.onBattery)
                return;

            const pct = Math.floor(UPower.displayDevice.percentage * 100);
            if (pct === notifiedLevel)
                return;

            if (pct <= 5 && notifiedLevel > 5) {
                notifiedLevel = 5;
                Quickshell.execDetached({
                    command: ['notify-send', 'Battery critically low', 'Emergency shutdown imminent unless plugged in.']
                });
            } else if (pct <= low_battery_level && notifiedLevel > low_battery_level) {
                notifiedLevel = low_battery_level;
                Quickshell.execDetached({
                    command: ['notify-send', 'Battery very low', 'Please plug in your charger now.']
                });
            } else if (pct <= 20 && notifiedLevel > 20) {
                notifiedLevel = 20;
                Quickshell.execDetached({
                    command: ['notify-send', 'Low battery', 'Consider plugging in your charger.']
                });
            }
        }
    }

    // Battery icon based on level
    property string icon: {
        if (!UPower.onBattery) return "bolt";
        if (UPower.displayDevice.percentage < 0.2) return "battery_1_bar";
        if (UPower.displayDevice.percentage < 0.4) return "battery_2_bar";
        if (UPower.displayDevice.percentage < 0.6) return "battery_4_bar";
        if (UPower.displayDevice.percentage < 0.8) return "battery_5_bar";
        return "battery_full";
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
        color: Colors.opacify(batteryColor, 0.2) // faint background tint

        RowLayout {
            id: textLayer
            anchors.centerIn: parent
            spacing: 4

            MaterialIcon {
                icon: root.icon
                font.pixelSize: 16
                color: batteryColor
            }

            Text {
                id: batteryText
                text: root.battery
                font.pixelSize: 12
                color: batteryColor
                font.bold: root.isLowBattery()
            }
        }

        Rectangle {
            id: bar
            clip: true
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: root.width * Math.min(Math.max(parseFloat(battery), 0), 100) / 100
            color: batteryColor

            Behavior on width {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }

            RowLayout {
                id: textLayer2
                x: (root.width - width) / 2
                y: (root.height - height) / 2
                spacing: 4

                MaterialIcon {
                    icon: root.icon
                    font.pixelSize: 16
                    color: Appearance.colors.m3surface
                }

                Text {
                    text: root.battery
                    font.pixelSize: 12
                    color: Appearance.colors.m3surface
                }
            }
        }
    }
}
