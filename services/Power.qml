pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.modules
import qs.preferences

Singleton {
    id: root

    readonly property var batteries: UPower.devices.values.filter(device => device.isLaptopBattery)
    readonly property bool onBattery: UPower.onBattery
    readonly property real percentage: laptop ? UPower.displayDevice.percentage ?? 0 : 0

    readonly property bool laptop: UPower.displayDevice.isLaptopBattery
    readonly property var displayDevice: UPower.displayDevice

    readonly property var powerProfileList: ["power-saver", "balanced", "performance"]
    property int powerProfileIndex: -1

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

            const p = root.percentage * 100;
            if (p <= 5 && root.notifiedLevel > 5) {
                root.notifiedLevel = 5;
                root.notify(
                    "Battery critically low",
                    "PLUG IN THE CHARGER ALREADY",
                    "critical"
                );
            } else if (p <= 10 && root.notifiedLevel > 10) {
                root.notifiedLevel = 10;
                root.notify(
                    "Battery very low",
                    "Please plug in the charger.",
                    "normal"
                );
            } else if (p <= 15 && root.notifiedLevel > 15) {
                root.notifiedLevel = 15;
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
                "notify-send",
                "-u", urgency,
                title,
                body
            ]
        })
    }

    Connections {
        target: root

        function onBatteryChanged() {
            if (!root.onBattery)
                root.notifiedLevel = 101
        }
    }

    function setPowerProfileIndex(index) {
        if (!_isValidPpIndex(index)) {
            Log.warn("services/Power.qml (setPowerProfileIndex)", "Out of range: " + index)
            return;
        }

        root.powerProfileIndex = index;
        ppcProc.command = [
            "powerprofilesctl",
            "set",
            root.powerProfileList[index]
        ];
        ppcProc.running = true;
    }

    function _isValidPpIndex(index) {
        return Number.isInteger(index) && index >= 0 && index < root.powerProfileList.length
    }

    Process {
        id: ppcProc

        command: []

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                Log.warn("services/Power.qml", "Failed to set power profile.")

                getPpcProc.running = true;
            }
        }
    }

    Process {
        id: getPpcProc

        command: ["powerprofilesctl", "get"]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim();
                const index = root.powerProfileList.indexOf(output);

                if (index === -1) {
                    Log.warn("services/Power.qml", "Unknown power profile: " + output)
                    return;
                }

                root.powerProfileIndex = index;
                Log.info("services/Power.qml", "Detected current mode: " + output + " (" + index + ")")
            }
        }
    }

    Component.onCompleted: {
        getPpcProc.running = true;
    }
}