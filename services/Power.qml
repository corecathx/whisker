pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.modules
import qs.preferences

Singleton {
    id: root

    readonly property var batteries: UPower.devices.values.filter(device => device.isLaptopBattery)
    readonly property bool onBattery: UPower.onBattery
    readonly property real percentage: laptop ? UPower.displayDevice.percentage : 0

    readonly property bool laptop: UPower.displayDevice.isLaptopBattery
    readonly property var displayDevice: UPower.displayDevice

    property int notifiedLevel: 101

    readonly property string chargingInfo: {
        let output = "";
        if (root.onBattery)
            output += Utils.formatSeconds(root.displayDevice.timeToEmpty) || "Calculating"
        else
            output += Utils.formatSeconds(root.displayDevice.timeToFull) || "Fully charged"

        return output
    }

    Connections {
        target: root
        function onPercentageChanged() {
            if (!root.onBattery)
                return;

            const p = percentage * 100;
            if (p <= 5 && notifiedLevel > 5) {
                notifiedLevel = 5;
                root.notify(
                    "Battery critically low",
                    "PLUG IN THE CHARGER ALREADY",
                    "critical"
                );
            } else if (p <= 10 && notifiedLevel > 10) {
                notifiedLevel = 10;
                root.notify(
                    "Battery very low",
                    "Please plug in the charger.",
                    "normal"
                );
            } else if (p <= 15 && notifiedLevel > 15) {
                notifiedLevel = 15;
                root.notify(
                    "Low battery",
                    "Battery's low, might wanna plug in the charger.",
                    "low"
                );
            }
        }
    }

    function notify(title, body, urgency = "normal") {
        Quickshell.execDetached({
            command: [
                'notify-send',
                '-u', urgency,
                title,
                body
            ]
        })
    }


    Connections {
        target: root
        function onOnBatteryChanged() {
            if (!root.onBattery)
                notifiedLevel = 101
        }
    }
}
