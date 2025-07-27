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

    color: !Bluetooth.enabled
        ? Colors.darken(Colors.accent, hovered ? 0 : 0.1)
        : Colors.lighten(Colors.accent, hovered ? 0.1 : 0.05)

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
            text: Bluetooth.label.length > 10
                ? Bluetooth.label.slice(0, 10) + "..."
                : Bluetooth.label
            font.pixelSize: 16
            color: Colors.foreground
        }

    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: hovered = true
        onExited: hovered = false
        onClicked: Bluetooth.toggle()
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: Bluetooth.refresh()
    }
}
