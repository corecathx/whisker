import qs.modules
import qs.components
import qs.preferences

import QtQuick
import QtQuick.Layouts

import Quickshell

BaseMenu {
    title: "Misc"
    description: "Additional settings."

    BaseCard {
        SwitchOption {
            title: "Visualizers"
            description: "Whether to display visualizer on the shell.\nSetting this to `false` would disable every visualizer on the shell."
            prefField: "misc.cavaEnabled"
        }

        SwitchOption {
            title: "Render Overview Windows"
            description: "Whether to render overview windows."
            prefField: "misc.renderOverviewWindows"
        }

        Divider {}

        TextFieldOption {
            title: "GitHub Username"
            description: "Your GitHub username.\nUsed in the GitHub Contribution Calendar widget."
            prefField: "misc.githubUsername"
        }

        GithubContribCalendar {
            Layout.alignment: Qt.AlignHCenter
        }

        Divider {}

        SwitchOption {
            title: "Use Lyrics Translation"
            description: "Show translated lyrics alongside the original lyrics.\n(Whisker uses Google Translate as its translation provider)"
            prefField: "misc.translateLyrics"
        }

        TextFieldOption {
            visible: Preferences.misc.translateLyrics
            title: "Lyrics Translation Language"
            description: "Target language code for lyrics translation.\nExamples: en, id, ja, ko, etc."
            prefField: "misc.lyricsLanguage"
        }

        Divider {}

        SwitchOption {
            title: "Show Stats Overlay"
            description: "Shows general information about the system (FPS, CPU Usage, and Memory Usage)"
            prefField: "misc.showStatsOverlay"
        }

        SwitchOption {
            title: "Activate Linux Overlay"
            description: "Displays a parody \"Activate Linux\" watermark, similar to the Windows activation message."
            prefField: "misc.activateLinuxOverlay"
        }
    }

    component Divider: Rectangle {
        height: 1
        Layout.fillWidth: true
        color: Appearance.colors.m3on_surface_variant
        opacity: 0.3
    }

    component SwitchOption: RowLayout {
        id: main
        property string title: "Title"
        property string description: "Description"
        property string prefField: ''

        ColumnLayout {
            StyledText {
                text: main.title
                font.pixelSize: 16
                color: Appearance.colors.m3on_background
            }
            StyledText {
                text: main.description
                font.pixelSize: 12
                color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
            }
        }

        Item {
            Layout.fillWidth: true
        }

        StyledSwitch {
            checked: Preferences[main.prefField.split('.')[0]][main.prefField.split('.')[1]]
            onToggled: {
                Quickshell.execDetached({
                    command: ['whisker', 'prefs', 'set', prefField, checked]
                });
            }
        }
    }

    component TextFieldOption: RowLayout {
        id: main
        property string title: "Title"
        property string description: "Description"
        property string prefField: ''

        ColumnLayout {
            StyledText {
                text: main.title
                font.pixelSize: 16
                color: Appearance.colors.m3on_background
            }
            StyledText {
                text: main.description
                font.pixelSize: 12
                color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
            }
        }

        Item {
            Layout.fillWidth: true
        }

        StyledTextField {
            text: Preferences[main.prefField.split('.')[0]][main.prefField.split('.')[1]]
            padding: 10
            leftPadding: undefined
            implicitWidth: 200
            onTextChanged: {
                Quickshell.execDetached({
                    command: ['whisker', 'prefs', 'set', main.prefField, text.toString()]
                });
            }
        }
    }
}
