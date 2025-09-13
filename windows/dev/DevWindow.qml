import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import qs.modules
import qs.components
import Qt.labs.platform
Scope {
    Window {
        id: win
        width: 600
        height: 400
        visible: true
        title: "Whisker Settings"
        color: Appearance.panel_color

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10
            StackLayout {
                id: stack
                Layout.fillWidth: true
                Layout.fillHeight: true

                Flickable {
                    contentWidth: parent.width
                    contentHeight: column1.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: column1
                        width: parent.width
                        spacing: 15

                        GroupBox {
                            title: "Notifications"
                            Layout.fillWidth: true

                            ColumnLayout {
                                spacing: 10

                                StyledButton {
                                    text: "Test notification (requires dunstify)"
                                    onClicked: notifProc.running = true

                                    Process {
                                        id: notifProc
                                        command: [
                                            "dunstify",
                                            "-u", "normal",
                                            "-i", "/home/corecat/.config/whisker/logo.png",
                                            "-h", "string:x-dunst-stack-tag:test",
                                            "-h", "int:value:50",
                                            "-A", "yes,Alright!",
                                            "-A", "no,Ehh...",
                                            "Whisker",
                                            "DevMode: Notification test."
                                        ]
                                    }
                                }

                                StyledButton {
                                    text: "Notif without actions"
                                    onClicked: notifProc2.running = true

                                    Process {
                                        id: notifProc2
                                        command: [
                                            "dunstify",
                                            "-i", "/home/corecat/.config/whisker/logo.png",
                                            "Whisker",
                                            "DevMode: Notification test."
                                        ]
                                    }
                                }
                                StyledButton {
                                    text: "Notif without icons"
                                    onClicked: notifProc4.running = true

                                    Process {
                                        id: notifProc4
                                        command: [
                                            "dunstify",
                                            "Whisker",
                                            "DevMode: Notification test."
                                        ]
                                    }
                                }
                                StyledButton {
                                    text: "Toggleable button"
                                    icon: "check"
                                    checkable: true
                                    onToggled: (state) => console.log("checked:", state)
                                }
                                StyledSwitch {
                                    id: customSwitch
                                    onToggled: console.log("Switch:", checked)
                                }



    FileDialog {
        id: fileDialog
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
    }


    StyledButton {
        text: "Open File Picker"
        anchors.centerIn: parent
        onClicked: fileDialog.open()
    }

                            }
                        }
                    }
                }

                // --- Tab 2: Sliders ---
                Flickable {
                    contentWidth: parent.width
                    contentHeight: column2.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: column2
                        width: parent.width
                        spacing: 15

                        GroupBox {
                            title: "Slider Test"
                            Layout.fillWidth: true

                            ColumnLayout {
                                spacing: 10
                                StyledSlider {
                                    Layout.fillWidth: true
                                    from: 0
                                    to: 100
                                    stepSize: 1
                                }
                            }
                        }
                    }
                }

                // --- Tab 3: About ---
                Flickable {
                    contentWidth: parent.width
                    contentHeight: column3.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: column3
                        width: parent.width
                        spacing: 15

                        GroupBox {
                            title: "About"
                            Layout.fillWidth: true

                            ColumnLayout {
                                spacing: 8
                                Label { text: "Whisker Settings Panel"; font.pixelSize: 18 }
                                Label { text: "Version: 1.0.0" }
                                Label { text: "Author: CoreCat" }
                            }
                        }
                    }
                }
            }
        }
    }
}
