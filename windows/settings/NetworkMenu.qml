import QtQuick
import QtQuick.Layouts
import Quickshell.Networking as QsNet
import qs.preferences
import qs.components
import qs.modules
import qs.services

BaseMenu {
    id: root
    title: "Network"
    description: "Manage network connections."

    property bool error: false
    property string errorNetworkName: ""
    property string errorMessage: ""

    BaseCard {
        BaseRowCard {
            cardSpacing: 0
            verticalPadding: Network.wifiEnabled ? 10 : 0
            cardMargin: 0
            StyledText {
                text: powerSwitch.checked ? "Wi-Fi: On" : "Wi-Fi: Off"
                font.pixelSize: 16
                font.bold: true
                color: Appearance.colors.m3on_background
            }
            Item { Layout.fillWidth: true }
            StyledSwitch {
                id: powerSwitch
                checked: Network.wifiEnabled
                onToggled: Network.enableWifi(checked)
            }//
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
                checked: Network.wifiDevice.scannerEnabled
                onToggled: {
                    Network.wifiDevice.scannerEnabled = checked
                }
            }
        }
    }

    InfoCard {
        visible: root.error
        icon: "error"
        backgroundColor: Appearance.colors.m3error
        contentColor: Appearance.colors.m3on_error
        title: "Failed to connect to " + Network.lastNetworkAttempt
        description: root.errorMessage
    }

    BaseCard {
        visible: !!Network.wifiNetwork
        StyledText {
            text: "Active Connection"
            font.pixelSize: 18
            font.bold: true
            color: Appearance.colors.m3on_background
        }

        NetworkCard {
            connection: Network.wifiNetwork
            menu: root
            isActive: true
            showDisconnect: true
        }
    }


    BaseCard {
        visible: Network.connections.filter(c => c.type === "ethernet").length > 0
        StyledText {
            text: "Ethernet"
            font.pixelSize: 18
            font.bold: true
            color: Appearance.colors.m3on_background
        }

        Repeater {
            model: Network.connections.filter(c => c.type === "ethernet" && !c.active)
            delegate: NetworkCard {
                connection: modelData
                menu: root
                showConnect: true
            }
        }
    }

    BaseCard {
        visible: Network.wifiEnabled
        StyledText {
            text: "Available Wi-Fi Networks"
            font.pixelSize: 18
            font.bold: true
            color: Appearance.colors.m3on_background
        }

        StyledText {
            Layout.fillWidth: true

            visible: Network.wifiEnabled &&
                    Network.wifiDevice &&
                    Network.wifiDevice.networks.values.filter(n => n && !n.connected).length === 0 &&
                    !Network.wifiDevice.scanning

            horizontalAlignment: Text.AlignHCenter
            text: "No networks found"
            font.pixelSize: 14
            color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
        }

        Repeater {
            model: Network.wifiDevice.networks.values.filter(c => c && !c.connected)
            delegate: NetworkCard {
                required property var modelData
                connection: modelData
                menu: root
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
            model: Network.wifiDevice.networks.values.filter(c => c.connected)
            delegate: NetworkCard {
                connection: modelData
                menu: root
                showConnect: false
                showDisconnect: false
            }
        }
    }
}
