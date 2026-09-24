import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.preferences
import qs.components
import qs.modules
import qs.services
BaseMenu {
    title: "VPN"
    description: "Manage your VPN connections."
    InfoCard {
        icon: "info"
        backgroundColor: Appearance.colors.m3primary
        contentColor: Appearance.colors.m3on_primary
        title: "Heads up!"
        description: "This menu is still being developed, so things might change overtime!"
    }

    InfoCard {
        visible: VPN.lastErrorMessage !== "" && VPN.lastErrorMessage !== "ok"
        icon: "error"
        backgroundColor: Appearance.colors.m3error
        contentColor: Appearance.colors.m3on_error
        title: "Failed to import/connect VPN"
        description: VPN.lastErrorMessage
    }

    BaseCard {
        StyledText {
            text: "VPN"
            font.pixelSize: 20
            font.bold: true
            color: Appearance.colors.m3on_background
        }
        RowLayout {
            StyledTextField {
                id: pathInput
                padding: 10
                leftPadding: undefined
                Layout.fillWidth: true
            }
            StyledButton {
                text: "Import WireGuard config"
                onClicked: {
                    Log.info("windows/settings/VPNMenu.qml", "OK " + pathInput.text)
                    VPN.importWireguard(pathInput.text)
                }
            }
        }
        ExpandableCard {
            id: vpnList
            title: VPN.active?.name ?? "Not connected"
            icon: "vpn_key"
            Repeater {
                model: VPN.connections
                delegate: BaseRowCard {
                    MaterialIcon {
                        icon: "vpn_key"
                        color: Appearance.colors.m3on_background
                        font.pixelSize: 32
                    }
                    StyledText {
                        text: modelData.name
                        color: Appearance.colors.m3on_background
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (modelData.active) VPN.disconnectVpn();
                            else VPN.connectVpn(modelData.name);
                            vpnList.expanded = false;
                        }
                    }
                }
            }
        }

    }

}
