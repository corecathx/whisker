import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.whisker.modules

Item {
    id:root
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    property bool verticalMode: false
    width:workspace.width
    height:workspace.height
    Workspaces {
        id: workspace
        verticalMode: root.verticalMode

    }
}


