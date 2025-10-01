import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules
import qs.components
import qs.services

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 20
    id: root

    property bool hovered: false

    color: {
        if (!Network.wifiEnabled) 
            return Colors.opacify(Appearance.colors.m3surface_variant, hovered ? 0.8 : 0.4)

        if (Network.active)
            return Colors.lighten(Appearance.colors.m3primary, hovered ? 0.1 : 0)

        // wifi enabled but not connected
        return Colors.lighten(Appearance.colors.m3secondary, hovered ? 0.1 : 0)
    }

    Behavior on color {
        ColorAnimation {
            duration: 100
            easing.type: Easing.OutCubic
        }
    }

    RowLayout {
        spacing: 10
        anchors.centerIn: parent

        MaterialIcon {
            icon: Network.icon
            font.pixelSize: 20
            color: {
                if (!Network.wifiEnabled)
                    return Appearance.colors.m3on_surface_variant
                if (Network.active)
                    return Appearance.colors.m3on_primary
                return Appearance.colors.m3on_secondary
            }
        }

        Text {
            text: {
                if (Network.active) {
                    if (Network.active.ssid.length > 12) {
                        return Network.active.ssid.slice(0, 12) + "..."
                    } else {
                        return Network.active.ssid
                    }
                } else {
                    return "Wi-Fi"
                }
            }
            font.pixelSize: 14
            color: {
                if (!Network.wifiEnabled)
                    return Appearance.colors.m3on_surface_variant
                if (Network.active)
                    return Appearance.colors.m3on_primary
                return Appearance.colors.m3on_secondary
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: hovered = true
        onExited: hovered = false
        onClicked: Network.toggleWifi()
    }
}
