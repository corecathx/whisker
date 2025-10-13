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
        if (!Bluetooth.defaultAdapter.enabled) // bt disabled
            return Colors.opacify(Appearance.colors.m3surface_variant, hovered ? 0.8 : 0.4)

        if (Bluetooth.activeDevice) // connected
            return hovered ? Appearance.colors.m3primary_container : Appearance.colors.m3primary_container

        // bt active but not connected
        return hovered ? Appearance.colors.m3secondary : Appearance.colors.m3secondary
    }

    Behavior on color {
        ColorAnimation {
            duration: 100
            easing.type: Appearance.animation.easing
        }
    }

    RowLayout {
        spacing: 10
        anchors.centerIn: parent

        MaterialIcon {
            icon: Bluetooth.icon
            font.pixelSize: 20
            color: {
                if (!Bluetooth.defaultAdapter.enabled)
                    return Appearance.colors.m3on_surface_variant
                if (Bluetooth.activeDevice)
                    return Appearance.colors.m3on_primary_container
                return Appearance.colors.m3on_secondary
            }
        }

        StyledText {
            text: {
                if (Bluetooth.activeDevice) {
                    if (Bluetooth.activeDevice.deviceName.length > 12) {
                        return Bluetooth.activeDevice.deviceName.slice(0, 12) + "..."
                    } else {
                        return Bluetooth.activeDevice.deviceName
                    }
                } else {
                    return "Bluetooth"
                }
            }
            font.pixelSize: 14
            color: {
                if (!Bluetooth.defaultAdapter.enabled)
                    return Appearance.colors.m3on_surface_variant
                if (Bluetooth.activeDevice)
                    return Appearance.colors.m3on_primary_container
                return Appearance.colors.m3on_secondary
            }
        }

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: hovered = true
        onExited: hovered = false
        onClicked: Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
    }
}
