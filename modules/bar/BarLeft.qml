import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules
import qs.services

Item {
    id: root
    property bool inLockScreen: false
    implicitHeight: childContent.height
    implicitWidth: childContent.width
    anchors.verticalCenter: parent.verticalCenter

    RowLayout {
        anchors.verticalCenter: parent.verticalCenter
        id: childContent
        spacing: 20
        Item {
            Layout.preferredWidth: userIcon.width + (Hyprland.currentWorkspace.hasTilingWindow() ? timeLabel.Layout.preferredWidth + 20 : timeLabel.Layout.preferredWidth)
            Layout.preferredHeight: userIcon.height
            UserIcon {
                id: userIcon
                visible: !root.inLockScreen 
                Layout.alignment: Qt.AlignVCenter
            }
            TimeLabel {
                id: timeLabel
                anchors.top: userIcon.top
                anchors.topMargin: (userIcon.height - timeLabel.height) * 0.5
                anchors.left: userIcon.right
                anchors.leftMargin: 20
                visible: !root.inLockScreen
                showLabel: Hyprland.currentWorkspace.hasTilingWindow()
            }
        }
        Stats {
            Layout.alignment: Qt.AlignVCenter
        }
        ActiveWindow {
            Layout.alignment: Qt.AlignVCenter
        }
        Tray {
            visible: !root.inLockScreen 
            Layout.alignment: Qt.AlignVCenter
        }

    }
}
