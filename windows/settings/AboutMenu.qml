import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.modules

Item {
    anchors.fill: parent

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24

        ColumnLayout {
            spacing: 12
            Layout.alignment: Qt.AlignHCenter

            Image {
                source: Appearance.whiskerIcon
                sourceSize: Qt.size(160, 160)
                fillMode: Image.PreserveAspectFit
                smooth: true
                Layout.alignment: Qt.AlignHCenter

                
            }

            ColumnLayout {
                spacing: 4
                Layout.alignment: Qt.AlignHCenter

                Text {
                    text: "Whisker Shell v0.1"
                    font.pixelSize: 20
                    font.bold: true
                    color: Colors.foreground
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "A simple shell focusing on usability."
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    color: Colors.foreground
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 320
                }
            }
        }
    }
}
