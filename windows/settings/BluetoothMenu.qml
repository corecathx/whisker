import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules
import qs.components
import qs.services
import QtQuick.Controls

Rectangle {
    color: "transparent"

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 20

        RowLayout {
            Text {
                text: "Bluetooth"
                font.pixelSize: 24
                font.bold: true
                color: Appearance.colors.m3on_background
            }
            Item {
                Layout.fillWidth: true
            }
            StyledSwitch {

            }
        }


        Column {
            spacing: 6

            Text {
                text: Bluetooth.enabled
                    ? (Bluetooth.connected
                        ? "Connected to: " + Bluetooth.connectedName
                        : "Not connected")
                    : "Bluetooth is turned off"
                font.pixelSize: 16
                color: Appearance.colors.m3on_background
                Layout.fillWidth: true
            }
        }

        Rectangle {
            height: 1
            color: Appearance.colors.m3on_background
            opacity: 0.2
            Layout.fillWidth: true
            visible: Bluetooth.enabled
        }
    }
}
