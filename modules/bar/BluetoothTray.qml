import QtQuick
import QtQuick.Layouts
import qs.components
import qs.modules
import qs.services
import Quickshell
Item {
    id: root
    property string icon: Bluetooth.icon
    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight

    visible: icon !== ""
    Layout.preferredWidth: visible ? implicitWidth : 0
    Layout.preferredHeight: visible ? implicitHeight : 0

    RowLayout {
        id: container
        MaterialIcon {
            id: iconLabel
            font.pixelSize: 20
            icon: root.icon
            color: Appearance.colors.m3on_background
        }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached({
                command: ['whisker', 'ipc', 'settings', 'open', 'bluetooth']
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
                    if (!Bluetooth.defaultAdapter?.enabled)
                        return "Bluetooth is off"
                    if (!Bluetooth.activeDevice)
                        return "Not connected"
                    return "Connected to \"" + (Bluetooth.activeDevice.name ||  Bluetooth.activeDevice.address) + "\""
                }
                color: Appearance.colors.m3on_surface
                font.pixelSize: 14
            }
        }
    }
}
