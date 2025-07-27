import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components
import qs.modules

Item {
    id: root
    property string status: "stopped"
    property string title: ""
    property string icon: status !== "Playing" ? "pause" : "play_arrow"

    implicitWidth: contentRow.implicitWidth
    implicitHeight: contentRow.implicitHeight
    visible: title !== ""

    Layout.preferredWidth: visible ? implicitWidth : 0
    Layout.preferredHeight: visible ? implicitHeight : 0

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: statusProc.running = true
    }

    RowLayout {
        id: contentRow

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: toggleProc.running = true
        }

        MaterialSymbol {
            icon: root.icon
            font.pixelSize: 20
            color: Colors.foreground
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: Colors.foreground
            font.pixelSize: 14
            text: root.title.length > 25 ? root.title.slice(0, 15) + "..." : root.title
            elide: Text.ElideRight
        }
    }

    Process {
        id: statusProc
        command: ["sh", "-c", "playerctl metadata --format '{{status}}|{{title}}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|")
                if (parts.length >= 2) {
                    root.status = parts[0]
                    root.title = parts[1]
                } else {
                    root.status = "stopped"
                    root.title = ""
                }
            }
        }
    }

    Process {
        id: toggleProc
        command: ["playerctl", "play-pause"]
    }
}
