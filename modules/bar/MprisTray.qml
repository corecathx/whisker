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

    property string title: Mpris.active?.trackTitle ?? ""
    property string icon: Mpris.active?.isPlaying ? "pause" : "play_arrow"

    width: contentRow.width
    implicitHeight: contentRow.implicitHeight
    visible: Mpris.active

    Layout.preferredWidth: visible ? implicitWidth : 0
    Layout.preferredHeight: visible ? implicitHeight : 0

    RowLayout {
        id: contentRow

        MouseArea {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!Mpris.active)
                    return;

                Mpris.active.isPlaying = !Mpris.active.isPlaying
            }
        }

        MaterialSymbol {
            Layout.alignment: Qt.AlignVCenter
            icon: root.icon
            font.pixelSize: 20
            color: Colors.foreground
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            color: Colors.foreground
            font.pixelSize: 14
            text: root.title.length > 25 ? root.title.slice(0, 15) + "..." : root.title
        }
    }
}
