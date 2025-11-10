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
    readonly property real percentage: UPower.displayDevice.percentage

    readonly property bool laptop: UPower.displayDevice.isLaptopBattery
    readonly property bool displayDevice: UPower.displayDevice

    readonly property string chargingInfo: {
        let output = "";
        if (Power.onBattery)
            output += Utils.formatSeconds(root.displayDevice.timeToEmpty) || "Calculating"
        else
            output += Utils.formatSeconds(root.displayDevice.timeToFull) || "Fully charged"

        return output
    }
}
