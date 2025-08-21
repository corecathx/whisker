import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import qs.modules
import qs.components

Scope {
    Window {
        id: win
        width: 600
        height: 320
        visible: true
        title: "Whisker Settings"
        color: Appearance.panel_color

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // --- Notification Section ---
            GroupBox {
                title: "Notifications"
                Layout.fillWidth: true
                ColumnLayout {
                    spacing: 10

                    StyledButton {
                        text: "Test notification (requires dunstify)"
                        onClicked: { notifProc.running = true }

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
                        text: "Notif without actions (requires dunstify)"
                        onClicked: { notifProc2.running = true }

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
                        text: "Toggleable button"
                        icon: "check"
                        checkable: true
                        onToggled: (state) => { console.log("checked:", state) }
                    }
                }
            }

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
}
