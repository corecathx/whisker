import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules

Item {
    anchors.fill: parent

    Rectangle {
        radius: 40
        color: "transparent"
        height: parent.height
        width: contentRow.implicitWidth
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: 10

            Workspaces {}
        }
    }
}


