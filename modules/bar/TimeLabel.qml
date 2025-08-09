import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import qs.modules
Item {
    id: root
    property string time
    property string date
    Layout.preferredWidth: width
    Layout.preferredHeight: height
    width: container.implicitWidth
    height: container.implicitHeight

    Column {
        spacing: -6
        id: container
        Text {
            id: label
            text: root.time
            color: Appearance.colors.m3on_background
            font.pixelSize: 20
            font.bold: true
            lineHeight: 0.1
            fontSizeMode: Text.Fit;
        }
        Text {
            id: date
            text: root.date
            color: Appearance.colors.m3on_background
            font.pixelSize: 14
            lineHeight: 0.1
            fontSizeMode: Text.Fit;
        }
    }
    
    Process {
        id: timeProc
        command: ["date", "+%H:%M"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.time = this.text.trim()
        }
    }
    Process {
        id: dateProc
        command: ["date", "+%A, %d/%m"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.date = this.text.trim()
        }
    }
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            timeProc.running = true
            dateProc.running = true
        }
    }
}
