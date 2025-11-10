import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import qs.components
import qs.modules
import qs.services

Item {
    id: root
    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    visible: Network.icon !== ""
    Layout.preferredWidth: visible ? implicitWidth : 0
    Layout.preferredHeight: visible ? implicitHeight : 0

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached({
                command: ['whisker', 'ipc', 'settings', 'open', 'wi-fi']
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
                    if (!Network.active) {
                        if (!Network.wifiEnabled) return "Wi-Fi is off";
                        return "Not connected";
                    }
                    if (Network.active.type === "ethernet") {
                        return "Connected via ethernet";
                    }
                    return "Connected to \"" + Network.active.name + '"';
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
            icon: Network.icon
            color: Appearance.colors.m3on_background
        }
    }
}
