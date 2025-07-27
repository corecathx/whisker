import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import qs.components
import qs.modules
Item {
    id: root
    property string icon
    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight

    visible: icon !== ""
    Layout.preferredWidth: visible ? implicitWidth : 0
    Layout.preferredHeight: visible ? implicitHeight : 0

    RowLayout {
        id: container
        MaterialSymbol {
            id: iconLabel
            font.pixelSize: 20
            icon: root.icon
            color: Colors.foreground
        }
    }

    Process {
        id: dateProc
        command: ["sh", "-c", "~/.config/quickshell/scripts/bluetooth.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.icon = this.text.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}
