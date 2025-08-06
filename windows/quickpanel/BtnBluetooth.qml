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
            return Colors.opacify(Colors.darken(Colors.accent, 0.15), hovered ? 1 : 0.4)
        if (Bluetooth.activeDevice) // connected
            return hovered ? Colors.accent : Colors.opacify(Colors.accent, 0.5)

        return hovered ? Colors.accent : Colors.opacify(Colors.accent, 0.5) // not connected but bt is active
    }

    border {
        width: 1
        color: Colors.accent
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

        MaterialSymbol {
            icon: Bluetooth.icon
            font.pixelSize: 24
            color: Colors.foreground
        }

        Text {
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
            color: Colors.foreground
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
