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

        Text {
            text: "Bluetooth"
            font.pixelSize: 24
            font.bold: true
            color: Appearance.colors.m3on_background
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

        ColumnLayout {
            id: list
            spacing: 10
            visible: Bluetooth.enabled && Bluetooth.availableDevices.length > 0

            Repeater {
                model: Bluetooth.availableDevices

                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 20
                    color: modelData.mac === Bluetooth.connectedName
                        ? Colors.opacify(Appearance.colors.m3primary, 0.7)
                        : Colors.opacify(Appearance.colors.m3on_background, 0.05)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        MaterialIcon {
                            icon: "bluetooth"
                            font.pixelSize: 18
                            color: Appearance.colors.m3on_background
                        }

                        Text {
                            text: modelData.name
                            font.pixelSize: 14
                            color: Appearance.colors.m3on_background
                            Layout.fillWidth: true
                        }

                        /*MaterialIcon {
                            visible: Bluetooth.pairedDevices.find(d => d.mac === modelData.mac) !== undefined
                            icon: "lock"
                            font.pixelSize: 16
                            color: Appearance.colors.m3on_background
                        }*/
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            let mac = modelData.mac
                            if (Bluetooth.connectedName === modelData.name) {
                                Bluetooth.disconnect(mac)
                            } else if (Bluetooth.pairedDevices.find(d => d.mac === mac)) {
                                Bluetooth.connect(mac)
                            } else {
                                pairDialog.openFor(modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: pairDialog
        modal: true
        focus: true
        width: 300
        height: 180
        padding: 16
        background: Rectangle {
            color: Appearance.colors.m3surface
            radius: 10
        }

        property var device: ({ name: "", mac: "" })
        signal openFor(var device)

        onOpenFor: {
            device = arguments[0]
            open()
        }

        ColumnLayout {
            spacing: 10
            anchors.fill: parent

            Text {
                text: "Pair with: " + device.name
                font.pixelSize: 16
                color: Appearance.colors.m3on_background
                wrapMode: Text.Wrap
            }

            Text {
                text: device.mac
                font.pixelSize: 14
                color: Appearance.colors.m3on_background
            }

            Button {
                text: "Pair"
                onClicked: {
                    Bluetooth.pair(device.mac)
                    pairDialog.close()
                }
            }
        }
    }
}
