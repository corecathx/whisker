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
            verticalPadding: Bluetooth.enabled ? 10 : 0
            cardMargin: 0
            StyledText {
                text: powerSwitch.checked ? "Power: On" : "Power: Off"
                font.pixelSize: 16
                font.bold: true
                color: Appearance.colors.m3on_background
            }
            Item {
                Layout.fillWidth: true
            }
            StyledSwitch {
                id: powerSwitch
                checked: Bluetooth.enabled
                onToggled: Bluetooth.setEnabled(checked)
            }
        }
        BaseRowCard {
            visible: Bluetooth.enabled
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
                    text: "Allow other devices to find this device."
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }
            Item {
                Layout.fillWidth: true
            }
            StyledSwitch {
                checked: Bluetooth.discoverable
                onToggled: Bluetooth.setDiscoverable(checked)
            }
        }
        BaseRowCard {
            visible: Bluetooth.enabled
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
            Item {
                Layout.fillWidth: true
            }
            StyledSwitch {
                checked: Bluetooth.scanning
                onToggled: Bluetooth.setScanning(checked)
            }
        }
    }

    BaseCard {
        visible: Bluetooth.devices.filter(d => d.connected).length > 0
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
                statusText: modelData.batteryAvailable ? "Connected, " + Math.floor(modelData.battery * 100) + "% left" : "Connected"
                showDisconnect: true
                showRemove: true
                usePrimary: true
            }
        }
    }

    BaseCard {
        visible: Bluetooth.enabled
        StyledText {
            text: "Paired Devices"
            font.pixelSize: 18
            font.bold: true
            color: Appearance.colors.m3on_background
        }


        RowLayout {
            opacity: 0.4
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            visible: pairedDevices.count === 0

            MaterialIcon {
                icon: "bluetooth_disabled"
                size: 64
                verticalAlignment: Text.AlignVCenter
                Layout.fillHeight: true
                color: Appearance.colors.m3on_surface_variant
            }
            StyledText {
                Layout.fillHeight: true

                verticalAlignment: Text.AlignVCenter
                text: "No devices found"
                font.bold: true
                font.pixelSize: 18
                color: Appearance.colors.m3on_surface_variant
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
                Layout.alignment: Qt.AlignHCenter
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
