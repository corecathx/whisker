import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules
import qs.services

Item {
    implicitHeight: 60
    property bool inLockScreen: false

    RowLayout {
        id: childContent
        anchors.fill: parent
        spacing: 10

        UserIcon {
            visible: !inLockScreen 
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            radius: 40
            color: "transparent"
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: contentRow.implicitWidth + (!inLockScreen ? 25 : 0)

            RowLayout {
                id: contentRow
                anchors.fill: parent
                anchors.margins: (!inLockScreen ? 10 : 0)
                spacing: 20

                TimeLabel {
                    visible: !inLockScreen
                    Layout.alignment: Qt.AlignVCenter
                    showLabel: Hyprland.currentWorkspace.hasTilingWindow()
                }
                Stats {
                    Layout.alignment: Qt.AlignVCenter
                }
                Tray {
                    visible: !inLockScreen 
                    Layout.alignment: Qt.AlignVCenter
                }

            }
        }
    }
}
