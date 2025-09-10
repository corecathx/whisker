import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components
import qs.modules
import qs.preferences
import qs.services

Item {
    id: root

    property string title: Players.active?.trackTitle ?? ""
    property string icon: Players.active?.isPlaying ? "pause" : "play_arrow"

    width: contentRow.width
    implicitHeight: contentRow.implicitHeight
    visible: Players.active

    Layout.preferredWidth: visible ? implicitWidth : 0
    Layout.preferredHeight: visible ? implicitHeight : 0

    RowLayout {
        id: contentRow

        MouseArea {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!Players.active)
                    return;

                Players.active.isPlaying = !Players.active.isPlaying
            }
        }

        MaterialIcon {
            Layout.alignment: Qt.AlignVCenter
            icon: root.icon
            font.pixelSize: 18
            color: Appearance.colors.m3on_background
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            color: Appearance.colors.m3on_background
            font.pixelSize: 12
            text: {
                return root.title.length > 15 ? root.title.slice(0, 15) + "..." : root.title
            }
        }
    }
}
