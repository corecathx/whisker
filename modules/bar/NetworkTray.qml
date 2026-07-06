import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import Quickshell.Networking as QsNet
import qs.components
import qs.modules
import qs.services

Item {
    id: root
    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    visible: !!Network.wifiDevice || !!Network.wiredDevice
    Layout.preferredWidth: visible ? implicitWidth : 0
    Layout.preferredHeight: visible ? implicitHeight : 0

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached({
                command: ["whisker", "ipc", "settings", "open", "network"]
            })
        }
    }

    HoverHandler {
        id: hover
    }

    StyledPopout {
        hoverTarget: hover
        hCenterOnItem: true
        Component {
            StyledText {
                text: {
                    if (!Network.wifiNetwork && !Network.wiredNetwork) {
                        if (!Network.wifiEnabled)
                            return "Wi-Fi is off";
                        return "Not connected";
                    }

                    switch (Network.connectivity) {
                    case QsNet.NetworkConnectivity.Portal:
                        return "Sign in to this network";

                    case QsNet.NetworkConnectivity.Limited:
                        return "Limited internet access";

                    case QsNet.NetworkConnectivity.None:
                        return "No internet access";

                    case QsNet.NetworkConnectivity.Unknown:
                        return "Checking connectivity...";
                    }

                    if (Network.wiredNetwork)
                        return "Connected via Ethernet";

                    return `Connected to "${Network.wifiNetwork.name}"`;
                }
                color: Appearance.colors.m3on_surface
                font.pixelSize: 14
            }
        }
    }

    RowLayout {
        id: container
        MaterialIcon {
            id: icon
            font.pixelSize: 20
            icon: {
                switch (Network.connectivity) {
                    case QsNet.NetworkConnectivity.Portal:
                        return "wifi_lock";

                    case QsNet.NetworkConnectivity.Limited:
                        return "wifi_find";

                    case QsNet.NetworkConnectivity.None:
                        return "signal_wifi_off";

                    case QsNet.NetworkConnectivity.Unknown:
                        return "hourglass_top";
                }

                if (Network.wiredNetwork)
                    return "settings_ethernet";

                if (!Network.wifiEnabled)
                    return "signal_wifi_off";

                if (!Network.wifiNetwork)
                    return "signal_wifi_bad";

                const level = Math.min(4, Math.floor(Network.wifiNetwork.signalStrength * 5));

                return [
                    "signal_wifi_0_bar",
                    "network_wifi_1_bar",
                    "network_wifi_2_bar",
                    "network_wifi_3_bar",
                    "signal_wifi_4_bar"
                ][level];
            }
            color: Appearance.colors.m3on_background
        }
    }
}