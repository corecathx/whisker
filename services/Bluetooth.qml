pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.modules
import qs.preferences

Singleton {
    readonly property BluetoothAdapter defaultAdapter: Bluetooth.defaultAdapter ?? null
    readonly property list<BluetoothDevice> devices: defaultAdapter?.devices?.values ?? []
    readonly property BluetoothDevice activeDevice: devices.find(d => d.connected) ?? null
    readonly property string icon: {
        if (!defaultAdapter?.enabled)
            return ""

        if (activeDevice)
            return "bluetooth_connected"

        return defaultAdapter.discovering
            ? "bluetooth_searching"
            : "bluetooth"
    }

}
