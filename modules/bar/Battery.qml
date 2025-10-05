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
    property bool verticalMode: false
    width: verticalMode ? 28 : 50
    height: verticalMode ? 50 : 25
    visible: UPower.displayDevice.isLaptopBattery

    property var low_battery_level: 15
    property int notifiedLevel: -1
    property string battery: UPower.displayDevice.isLaptopBattery 
        ? (Math.round(UPower.displayDevice.percentage * 100).toFixed(1)) + "" 
        : "0%"

    property color batteryColor: {
        if (!UPower.onBattery) {
            return Appearance.colors.m3primary;
        }
        if (UPower.displayDevice.percentage < 0.2) {
            return Appearance.colors.m3error;
        }
        if (UPower.displayDevice.percentage < 0.5) {
            return Appearance.colors.m3secondary;
        }
        return Appearance.colors.m3primary;
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

    property string icon: {
        if (!UPower.onBattery) return "bolt";
        return "";
    }

    ClippingRectangle {
        id: background
        anchors.fill: parent
        radius: 100
        color: Colors.opacify(batteryColor, 0.2)

        RowLayout {
            id: textLayer
            anchors.centerIn: parent
            spacing: 0

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
            anchors.top: verticalMode ? undefined : parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: verticalMode ? parent.right : undefined
            width: verticalMode ? root.width : root.width * Math.min(Math.max(parseFloat(battery), 0), 100) / 100
            height: verticalMode ? root.height * Math.min(Math.max(parseFloat(battery), 0), 100) / 100 : root.height
            color: batteryColor

            Behavior on width {
                NumberAnimation { duration: 300; easing.type: Easing.OutExpo }
            }

            RowLayout {
                id: textLayer2
                x: (root.width - width) / 2
                y: (root.height - height) / 2
                spacing: 0

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
