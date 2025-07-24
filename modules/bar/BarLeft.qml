import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules

Item {
    implicitHeight: 60

    RowLayout {
        id: childContent
        anchors.fill: parent
        spacing: 10

        UserIcon {
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            radius: 40
            color: "transparent"
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: contentRow.implicitWidth + 25

            RowLayout {
                id: contentRow
                anchors.fill: parent
                anchors.margins: 10
                spacing: 30
                // removed anchors.centerIn, it’s not needed

                TimeLabel {
                    Layout.alignment: Qt.AlignVCenter
                }
                Tray {
                    Layout.alignment: Qt.AlignVCenter
                }
                Stats {
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }
}
