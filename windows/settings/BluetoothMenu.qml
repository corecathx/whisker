import QtQuick
import QtQuick.Layouts
import qs.preferences
import qs.components
import qs.modules
import qs.services
import Quickshell.Bluetooth as QsBluetooth

BaseMenu {
    title: "Bluetooth"
    description: "Manage Bluetooth devices and connections."

    BaseCard {
        BaseRowCard {
            cardSpacing: 0
            verticalPadding: Bluetooth.defaultAdapter.enabled ? 10 : 0
            cardMargin: 0
            StyledText {
                text: powerSwitch.checked ? "Power: On" : "Power: Off"
                font.pixelSize: 16
                font.bold: true
                color: Appearance.colors.m3on_background
            }
            Item { Layout.fillWidth: true }
            StyledSwitch {
                id: powerSwitch
                checked: Bluetooth.defaultAdapter?.enabled
                onToggled: Bluetooth.defaultAdapter.enabled = checked
            }
        }
        BaseRowCard {
            visible: Bluetooth.defaultAdapter.enabled
            cardSpacing: 0
            verticalPadding: 10
            cardMargin: 0
            ColumnLayout {
                spacing: 2
                StyledText {
                    text: "Discoverable"
                    font.pixelSize: 16
                    color: Appearance.colors.m3on_background
                }
                StyledText {
                    text: "Allow other devices to find this computer."
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }
            Item { Layout.fillWidth: true }
            StyledSwitch {
                checked: Bluetooth.defaultAdapter?.discoverable
                onToggled: Bluetooth.defaultAdapter.discoverable = checked
            }
        }
        BaseRowCard {
            visible: Bluetooth.defaultAdapter.enabled
            cardSpacing: 0
            verticalPadding: 0
            cardMargin: 0
            ColumnLayout {
                spacing: 2
                StyledText {
                    text: "Scanning"
                    font.pixelSize: 16
                    color: Appearance.colors.m3on_background
                }
                StyledText {
                    text: "Search for nearby Bluetooth devices."
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }
            Item { Layout.fillWidth: true }
            StyledSwitch {
                checked: Bluetooth.defaultAdapter?.discovering
                onToggled: Bluetooth.defaultAdapter.discovering = checked
            }
        }
    }


    BaseCard {
        visible: connectedDevices.count > 0
        StyledText {
            text: "Connected Devices"
            font.pixelSize: 18
            font.bold: true
            color: Appearance.colors.m3on_background
        }

        Repeater {
            id: connectedDevices
            model: Bluetooth.devices.filter(d => d.connected)
            delegate: BluetoothDeviceCard {
                device: modelData
                statusText: modelData.batteryAvailable
                            ? "Connected, " + Math.floor(modelData.battery * 100) + "% left"
                            : "Connected"
                showDisconnect: true
                showRemove: true
                usePrimary: true
            }
        }
    }

    BaseCard {
        visible: Bluetooth.defaultAdapter?.enabled
        StyledText {
            text: "Paired Devices"
            font.pixelSize: 18
            font.bold: true
            color: Appearance.colors.m3on_background
        }

        Item {
            visible: pairedDevices.count === 0
            width: parent.width
            height: 40
            StyledText {
                anchors.centerIn: parent
                text: "No paired devices"
                font.pixelSize: 14
                color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
            }
        }

        Repeater {
            id: pairedDevices
            model: Bluetooth.devices.filter(d => !d.connected && d.paired)
            delegate: BluetoothDeviceCard {
                device: modelData
                statusText: "Not connected"
                showConnect: true
                showRemove: true
            }
        }
    }

    BaseCard {
        visible: Bluetooth.defaultAdapter?.enabled
        StyledText {
            text: "Available Devices"
            font.pixelSize: 18
            font.bold: true
            color: Appearance.colors.m3on_background
        }

        Item {
            visible: discoveredDevices.count === 0 && !Bluetooth.defaultAdapter.discovering
            width: parent.width
            height: 40
            StyledText {
                anchors.centerIn: parent
                text: "No new devices found"
                font.pixelSize: 14
                color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
            }
        }

        Repeater {
            id: discoveredDevices
            model: Bluetooth.devices.filter(d => !d.paired && !d.connected)
            delegate: BluetoothDeviceCard {
                device: modelData
                statusText: "Discovered"
                showConnect: true
                showPair: true
            }
        }
    }
}
