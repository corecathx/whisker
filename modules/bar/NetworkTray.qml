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
                    if (!Network.wifiEnabled)
                        return "Wi-Fi is off"
                    if (!Network.active)
                        return "Not connected";
                    return "Connected to \"" + Network.active.ssid + '"'
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
