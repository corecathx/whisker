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
            color: Colors.foreground
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
                color: Colors.foreground
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 10
                Layout.fillWidth: true
                visible: Network.wifi.enabled && Network.wifi.currentName.length > 0

                MaterialSymbol {
                    icon: Network.wifi.icon
                    font.pixelSize: 20
                    color: Colors.foreground
                }

                Text {
                    text: Network.wifi.strength + "%"
                    font.pixelSize: 14
                    color: Colors.foreground
                }
            }
        }

        Rectangle {
            height: 1
            color: Colors.foreground
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
                        ? Colors.opacify(Colors.accent, 0.7)
                        : Colors.opacify(Colors.foreground, 0.05)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        MaterialSymbol {
                            icon: modelData === Network.wifi.currentName
                                ? Network.wifi.icon
                                : "network_wifi"
                            font.pixelSize: 18
                            color: Colors.foreground
                        }

                        Text {
                            text: modelData
                            font.pixelSize: 14
                            color: Colors.foreground
                            Layout.fillWidth: true
                        }

                        MaterialSymbol {
                            visible: Network.wifi.isSecured(modelData)
                            icon: "lock"
                            font.pixelSize: 16
                            color: Colors.foreground
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
            color: Colors.background
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
                color: Colors.foreground
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
