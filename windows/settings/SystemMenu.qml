import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.modules
import qs.components
import qs.services

Rectangle {
    id: root
    color: "transparent"

    property string systemUserHost: "Loading..."

    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        anchors.margins: 20

        RowLayout {
            spacing: 20
            Layout.alignment: Qt.AlignHCenter

            Image {
                id: logo
                width: 96
                height: 96
                smooth: true
                Process {
                    running: true
                    command: ["sh", "-c", ". /etc/os-release && echo $LOGO"]
                    stdout: StdioCollector {
                        onStreamFinished: logo.source = Quickshell.iconPath(text.trim())
                    }
                }
            }

            ColumnLayout {
                Text {
                    text: root.systemUserHost
                    font.pixelSize: 22
                    font.bold: true
                    color: Appearance.colors.m3on_background
                }
                Text {
                    text: root.systemDevice
                    font.pixelSize: 14
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.7)
                }
            }
        }

    }

    Process { command: ["sh", "-c", "echo $(whoami)@$(hostnamectl --static)"]; running: true;
        stdout: StdioCollector { onStreamFinished: root.systemUserHost = text.trim() } }
}
