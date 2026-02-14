import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.preferences
import qs.components
import qs.components.filepicker
import qs.modules
import qs.services

BaseMenu {
    title: "User"
    description: "Current user's profile."

    InfoCard {
        icon: "info"
        backgroundColor: Appearance.colors.m3tertiary
        contentColor: Appearance.colors.m3on_tertiary
        title: "Root privileges required."
        description: "Some changes need root access, so you'll get prompted if needed."
    }

    BaseCard {
        SectionTitle {
            icon: "portrait"
            text: "Profile Picture"
        }

        Item {
            id: userIcon
            Layout.alignment: Qt.AlignHCenter
            width: icon.width
            height: icon.height

            ProfileIcon {
                id: icon
                implicitWidth: 150
            }

            StyledButton {
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }
                icon: "edit"
                onClicked: imagePicker.open()
            }

            Process {
                id: setPfpProc
                onExited: {
                    if (exitCode !== 0) {
                        Quickshell.execDetached(["whisker", "notify", "Whisker", "Failed to set profile picture"]);
                        return;
                    }
                    Appearance.refreshProfileImage();
                    Quickshell.execDetached(["whisker", "notify", "Whisker", "Profile picture updated!"]);
                }
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: "Click the edit button to change"
            font.pixelSize: 12
            color: Appearance.colors.m3on_surface_variant
        }
    }

    BaseCard {
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16

            SectionTitle {
                icon: "badge"
                text: "Your Info"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                StyledText {
                    text: "Username"
                    color: Appearance.colors.m3on_surface_variant
                    Layout.preferredWidth: 120
                }

                StyledText {
                    text: Quickshell.env("USER")
                    color: Appearance.colors.m3on_surface
                    font.weight: Font.Medium
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                StyledText {
                    text: "Home"
                    color: Appearance.colors.m3on_surface_variant
                    Layout.preferredWidth: 120
                }

                StyledText {
                    text: Quickshell.env("HOME")
                    color: Appearance.colors.m3on_surface
                    font.weight: Font.Medium
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                StyledText {
                    text: "Shell"
                    color: Appearance.colors.m3on_surface_variant
                    Layout.preferredWidth: 120
                }

                StyledText {
                    text: Quickshell.env("SHELL") || "not set"
                    color: Appearance.colors.m3on_surface
                    font.weight: Font.Medium
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                StyledText {
                    text: "Last Login"
                    color: Appearance.colors.m3on_surface_variant
                    Layout.preferredWidth: 120
                }

                StyledText {
                    id: lastLoginText
                    text: "Loading..."
                    color: Appearance.colors.m3on_surface
                    font.weight: Font.Medium
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                StyledText {
                    text: "Account Created"
                    color: Appearance.colors.m3on_surface_variant
                    Layout.preferredWidth: 120
                }

                StyledText {
                    id: accountCreatedText
                    text: "Loading..."
                    color: Appearance.colors.m3on_surface
                    font.weight: Font.Medium
                }
            }
        }

        Process {
            id: getLastLoginProc
            running: true
            command: ["bash", "-c", "lastlog -u " + Quickshell.env("USER") + " | tail -n 1 | awk '{print $4, $5, $6, $9}'"]
            stdout: StdioCollector {
                onStreamFinished: {
                    var result = text.trim()
                    lastLoginText.text = result !== "" && !result.includes("Never") ? result : "Never logged in"
                }
            }
        }

        Process {
            id: getAccountCreatedProc
            running: true
            command: ["bash", "-c", "stat -c %w " + Quickshell.env("HOME") + " 2>/dev/null || stat -c %y " + Quickshell.env("HOME")]
            stdout: StdioCollector {
                onStreamFinished: {
                    var timestamp = text.trim().split(' ')[0]
                    accountCreatedText.text = timestamp || "Unknown"
                }
            }
        }
    }


    FilePicker {
        id: imagePicker
        title: "Pick a profile picture"
        filterLabel: "Images"
        filters: ["png", "jpg", "jpeg", "gif", "svg", "webp"]
        onAccepted: path => {
            setPfpProc.command = ['whisker', 'users', Quickshell.env('USER'), 'icon', path];
            setPfpProc.running = true
        }
        onRejected: {
        }
    }
}
