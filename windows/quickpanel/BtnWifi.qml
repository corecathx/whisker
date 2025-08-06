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

    color: !Network.wifi.enabled
        ? Colors.opacify(Colors.accent, hovered ? 0.6 : 0.5)
        : Colors.lighten(Colors.accent, hovered ? 0.1 : -0.1)

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
            icon: Network.wifi.icon
            font.pixelSize: 24
            color: Colors.foreground
        }

        Text {
            text: {
                if (!Network.wifi.enabled)
                    return "Wi-Fi"
                const name = Network.wifi.currentName
                return name.length > 15 ? name.slice(0, 15) + "..." : (name || "Wi-Fi")
            }
            font.pixelSize: 16
            color: Colors.foreground
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: Network.wifi.toggle()
    }
}
