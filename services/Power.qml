pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.modules
import qs.preferences

Singleton {
    readonly property var batteries: UPower.devices.values.filter(device => device.isLaptopBattery)
    readonly property bool onBattery: UPower.onBattery
    readonly property real percentage: UPower.displayDevice.percentage

    readonly property bool laptop: UPower.displayDevice.isLaptopBattery
    readonly property bool displayDevice: UPower.displayDevice
}
