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
        onClicked: clickProc.running = true
    }

    RowLayout {
        id: container
        MaterialSymbol {
            id: icon
            font.pixelSize: 20
            icon: Network.icon
            color: Colors.foreground
        }
    }
}
