import QtQuick
import QtQuick.Layouts
import qs.preferences
import qs.components
import qs.modules
import qs.services

BaseMenu {
    title: "Wi-Fi"
    description: "Manage Wi-Fi networks and connections."

    BaseCard {
        BaseRowCard {
            cardSpacing: 0
            verticalPadding: Network.wifiEnabled ? 10 : 0
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
                checked: Network.wifiEnabled
                onToggled: Network.enableWifi(checked)
            }
        }

        BaseRowCard {
            visible: Network.wifiEnabled
            cardSpacing: 0
            verticalPadding: 10
            cardMargin: 0
            ColumnLayout {
                spacing: 2
                StyledText {
                    text: "Scanning"
                    font.pixelSize: 16
                    color: Appearance.colors.m3on_background
                }
                StyledText {
                    text: "Search for nearby Wi-Fi networks."
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }
            Item { Layout.fillWidth: true }
            StyledSwitch {
                checked: Network.scanning
                onToggled: {
                    if (checked) Network.rescanWifi()
                }
            }
        }
    }
    InfoCard {
        visible: Network.message !== "" && Network.message !== "ok"
        icon: "error"
        backgroundColor: Appearance.colors.m3error
        contentColor: Appearance.colors.m3on_error
        title: "Failed to connect to " + Network.lastNetworkAttempt
        description: Network.message
    }
    BaseCard {
        visible: Network.active !== null
        StyledText {
            text: "Connected Network"
            font.pixelSize: 18
            font.bold: true
            color: Appearance.colors.m3on_background
        }

        WifiNetworkCard {
            network: Network.active
            isActive: true
            showDisconnect: true
        }
    }

    BaseCard {
        visible: Network.wifiEnabled
        StyledText {
            text: "Available Networks"
            font.pixelSize: 18
            font.bold: true
            color: Appearance.colors.m3on_background
        }

        Item {
            visible: Network.networks.length === 0 && !Network.scanning
            width: parent.width
            height: 40
            StyledText {
                anchors.centerIn: parent
                text: "No networks found"
                font.pixelSize: 14
                color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
            }
        }

        Repeater {
            model: Network.networks.filter(n => !n.active)
            delegate: WifiNetworkCard {
                network: modelData
                showConnect: true
            }
        }
    }
    BaseCard {
        visible: Network.savedNetworks.length > 0
        StyledText {
            text: "Remembered Networks"
            font.pixelSize: 18
            font.bold: true
            color: Appearance.colors.m3on_background
        }

        Item {
            visible: Network.savedNetworks.length === 0
            width: parent.width
            height: 40
            StyledText {
                anchors.centerIn: parent
                text: "No remembered networks"
                font.pixelSize: 14
                color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
            }
        }

        Repeater {
            model: Network.networks.filter(n => n.saved)
            delegate: WifiNetworkCard {
                network: modelData
                showConnect: false
                showDisconnect: false
            }
        }
    }

}
