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
            text: "Wi-Fi"
            font.pixelSize: 24
            font.bold: true
            color: Appearance.colors.m3on_background
        }

        Column {
            spacing: 6

            Text {
                text: Network.wifi.enabled
                    ? (Network.wifi.currentName.length > 0
                        ? "Connected to: " + Network.wifi.currentName
                        : "Not connected")
                    : "Wi-Fi is turned off"
                font.pixelSize: 16
                color: Appearance.colors.m3on_background
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 10
                Layout.fillWidth: true
                visible: Network.wifi.enabled && Network.wifi.currentName.length > 0

                MaterialIcon {
                    icon: Network.wifi.icon
                    font.pixelSize: 20
                    color: Appearance.colors.m3on_background
                }

                Text {
                    text: Network.wifi.strength + "%"
                    font.pixelSize: 14
                    color: Appearance.colors.m3on_background
                }
            }
        }

        Rectangle {
            height: 1
            color: Appearance.colors.m3on_background
            opacity: 0.2
            Layout.fillWidth: true
            visible: Network.wifi.enabled
        }

        ColumnLayout {
            id: list
            spacing: 10
            visible: Network.wifi.enabled && Network.wifi.list.length > 0

            Repeater {
                model: Network.wifi.list

                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 20
                    color: modelData === Network.wifi.currentName
                        ? Colors.opacify(Appearance.colors.m3primary, 0.7)
                        : Colors.opacify(Appearance.colors.m3on_background, 0.05)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        MaterialIcon {
                            icon: modelData === Network.wifi.currentName
                                ? Network.wifi.icon
                                : "network_wifi"
                            font.pixelSize: 18
                            color: Appearance.colors.m3on_background
                        }

                        Text {
                            text: modelData
                            font.pixelSize: 14
                            color: Appearance.colors.m3on_background
                            Layout.fillWidth: true
                        }

                        MaterialIcon {
                            visible: Network.wifi.isSecured(modelData)
                            icon: "lock"
                            font.pixelSize: 16
                            color: Appearance.colors.m3on_background
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            let ssid = modelData
                            if (Network.wifi.currentName === ssid) {
                                Network.wifi.disconnect()
                            } else if (Network.wifi.isKnown(ssid)) {
                                Network.wifi.connectTo(ssid)
                            } else if (Network.wifi.isSecured(ssid)) {
                                passwordDialog.openFor(ssid)
                            } else {
                                Network.wifi.connectTo(ssid)
                            }
                        }
                    }
                }

            }
        }
    }

    Popup {
        id: passwordDialog
        modal: true
        focus: true
        width: 300
        height: 180
        padding: 16
        background: Rectangle {
            color: Appearance.colors.m3surface
            radius: 10
        }

        property string ssid: ""
        signal openFor(string ssid)

        onOpenFor: {
            ssid = arguments[0]
            passwordField.text = ""
            open()
        }

        ColumnLayout {
            spacing: 10
            anchors.fill: parent

            Text {
                text: "Enter password for: " + ssid
                font.pixelSize: 16
                color: Appearance.colors.m3on_background
                wrapMode: Text.Wrap
            }

            TextField {
                id: passwordField
                echoMode: TextInput.Password
                placeholderText: "Password"
                font.pixelSize: 14
                Layout.fillWidth: true
            }

            Button {
                text: "Connect"
                onClicked: {
                    Network.wifi.connectTo(ssid, passwordField.text)
                    passwordDialog.close()
                }
            }
        }
    }

}
