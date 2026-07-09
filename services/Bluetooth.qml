pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.modules
import qs.preferences

Singleton {
    id: root
    readonly property BluetoothAdapter defaultAdapter: Bluetooth.defaultAdapter
    readonly property bool enabled: root.defaultAdapter?.enabled ?? false
    readonly property bool scanning: root.defaultAdapter?.discovering ?? false
    readonly property bool discoverable: root.defaultAdapter?.discoverable ?? false

    function setEnabled(enable) {
        root.defaultAdapter.enabled = enable
    }

    function setScanning(enable) {
        root.defaultAdapter.discovering = enable
    }

    function setDiscoverable(enable) {
        root.defaultAdapter.discoverable = enable
    }

    function isChangingState(device) {
        return (device.state !== BluetoothDeviceState.Connected
            && device.state !== BluetoothDeviceState.Disconnected)
            || device.pairing
    }

    readonly property list<BluetoothDevice> devices: defaultAdapter?.devices?.values ?? []
    readonly property BluetoothDevice activeDevice: devices.find(d => d.connected) ?? null
    readonly property string icon: {
        if (!defaultAdapter?.enabled)
            return "bluetooth_disabled"

        if (activeDevice)
            return "bluetooth_connected"

        return defaultAdapter.discovering
            ? "bluetooth_searching"
            : "bluetooth"
    }

}
