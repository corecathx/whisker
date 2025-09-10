import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules

Item {
    anchors.fill: parent

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width:workspace.width
        height:workspace.height
        Workspaces {
            id: workspace

        }
    }


}


