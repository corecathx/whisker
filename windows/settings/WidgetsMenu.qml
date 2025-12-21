import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.modules
import qs.components
import qs.preferences
import qs.services

BaseMenu {
    title: "Widgets"
    description: "Configure widgets and overlays displayed on your desktop."

    BaseCard {
        ColumnLayout {
            width: parent.width
            spacing: 16

            SectionTitle { icon: "bar_chart"; text: "Visualizers" }
            SwitchOption { title: "Enable Visualizers"; description: "Display audio visualizers on the shell"; prefField: "misc.cavaEnabled" }
            SwitchOption { title: "Render Overview Windows"; description: "Render window previews in the overview"; prefField: "misc.renderOverviewWindows" }
        }
    }

    BaseCard {
        ColumnLayout {
            width: parent.width
            spacing: 16

            SectionTitle { icon: "lyrics"; text: "Music Widget" }
            SwitchOption { title: "Show Lyrics"; description: "Display song lyrics on your desktop"; prefField: "widgets.showLyrics" }
            SwitchOption { visible: Preferences.widgets.showLyrics; title: "Lyrics Overlay Mode"; description: "Show lyrics on top of all windows instead of just the desktop"; prefField: "widgets.lyricsAsOverlay" }
            SwitchOption { visible: Preferences.widgets.showLyrics; title: "Translate Lyrics"; description: "Display translated lyrics alongside the original text"; prefField: "misc.translateLyrics" }
            TextFieldOption { visible: Preferences.misc.translateLyrics && Preferences.widgets.showLyrics; title: "Translation Language"; description: "Language code for translations (e.g., en, id, ja, ko)"; prefField: "misc.lyricsLanguage"; placeholder: "en" }

            Item {
                visible: Preferences.misc.translateLyrics && Preferences.widgets.showLyrics;
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    MaterialIcon { icon: "translate"; font.pixelSize: 32; color: Colors.opacify(Appearance.colors.m3on_surface, 0.3); Layout.alignment: Qt.AlignHCenter }
                    StyledText { text: "Powered by Google Translate"; font.pixelSize: 11; color: Colors.opacify(Appearance.colors.m3on_surface, 0.5); Layout.alignment: Qt.AlignHCenter }
                }
            }
        }
    }

    BaseCard {
        ColumnLayout {
            width: parent.width
            spacing: 16

            SectionTitle { icon: "schedule"; text: "Desktop" }
            SwitchOption { title: "Desktop Clock"; description: "Display time and date on your desktop"; prefField: "widgets.desktop.clock" }
            SwitchOption { title: "Desktop Player"; description: "Show a music player widget on your desktop"; prefField: "widgets.desktop.player" }
        }
    }

    BaseCard {
        ColumnLayout {
            width: parent.width
            spacing: 16

            SectionTitle { icon: "code"; text: "GitHub Widget" }
            TextFieldOption { title: "GitHub Username"; description: "Your GitHub username for the contribution calendar"; prefField: "misc.githubUsername"; placeholder: "octocat" }

            Item {
                visible: Preferences.misc.githubUsername !== ""
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                StyledText { anchors.centerIn: parent; text: "Preview"; font.pixelSize: 13; font.family: "Outfit SemiBold"; color: Colors.opacify(Appearance.colors.m3on_surface, 0.6) }
            }

            GithubContribCalendar { visible: Preferences.misc.githubUsername !== ""; Layout.alignment: Qt.AlignHCenter }
        }
    }

    BaseCard {
        ColumnLayout {
            width: parent.width
            spacing: 16

            SectionTitle { icon: "tune"; text: "Misc" }
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
    }

    component SectionTitle: RowLayout {
        id: section
        property string icon: ""
        property string text: ""
        Layout.fillWidth: true
        spacing: 10
        MaterialIcon { icon: section.icon; color: Appearance.colors.m3primary; font.pixelSize: 22 }
        StyledText { text: section.text; font.pixelSize: 17; font.family: "Outfit SemiBold"; color: Appearance.colors.m3on_surface }
    }

    component SwitchOption: RowLayout {
        id: switchOpt
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing } }
        property string title: ""
        property string description: ""
        property string prefField: ""
        Layout.fillWidth: true
        spacing: 12
        ColumnLayout {
            spacing: 2
            StyledText { text: switchOpt.title; font.pixelSize: 15; color: Appearance.colors.m3on_surface }
            StyledText { text: switchOpt.description; font.pixelSize: 12; color: Colors.opacify(Appearance.colors.m3on_surface, 0.6) }
        }
        Item { Layout.fillWidth: true }
        StyledSwitch {
            Layout.alignment: Qt.AlignVCenter
            checked: Preferences[switchOpt.prefField.split('.')[0]][switchOpt.prefField.split('.')[1]]
            onToggled: { Quickshell.execDetached({ command: ['whisker', 'prefs', 'set', switchOpt.prefField, checked] }) }
        }
    }

    component TextFieldOption: RowLayout {
        id: textOpt
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing } }
        property string title: ""
        property string description: ""
        property string prefField: ""
        property string placeholder: ""
        Layout.fillWidth: true
        spacing: 12
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            StyledText { text: textOpt.title; font.pixelSize: 15; color: Appearance.colors.m3on_surface }
            StyledText { text: textOpt.description; font.pixelSize: 12; color: Colors.opacify(Appearance.colors.m3on_surface, 0.6) }
        }
        Item { Layout.fillWidth: true }
        StyledTextField {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 180
            text: Preferences[textOpt.prefField.split('.')[0]][textOpt.prefField.split('.')[1]]
            placeholderText: textOpt.placeholder
            fieldPadding: 10
            onTextChanged: { Quickshell.execDetached({ command: ['whisker', 'prefs', 'set', textOpt.prefField, text.toString()] }) }
        }
    }
}
