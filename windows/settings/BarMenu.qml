import Quickshell.Widgets
import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import qs.modules
import qs.components
import qs.preferences

BaseMenu {
    title: "Bar"
    description: "Adjust how the Bar panel behaves."

    BaseCard {
        StyledText {
            text: "Bar"
            font.pixelSize: 20
            font.bold: true
            color: Appearance.colors.m3on_background
        }

        ColumnLayout {
            StyledText {
                text: "Position"
                font.pixelSize: 16
                color: Appearance.colors.m3on_background
            }
            RowLayout {
                Repeater {
                    model: ['Left', 'Bottom', 'Top', 'Right']
                    delegate: StyledButton {
                        text: modelData
                        // checkable: true
                        Layout.fillWidth: true
                        implicitWidth: 0
                        checked: Preferences.barPosition === modelData.toLowerCase()
                        topLeftRadius: modelData == "Left" || Preferences.barPosition === modelData.toLowerCase() ? 20 : 5
                        bottomLeftRadius: modelData == "Left" || Preferences.barPosition === modelData.toLowerCase() ? 20 : 5
                        topRightRadius: modelData == "Right" || Preferences.barPosition === modelData.toLowerCase() ? 20 : 5
                        bottomRightRadius: modelData == "Right" || Preferences.barPosition === modelData.toLowerCase() ? 20 : 5

                        onClicked: {
                            Quickshell.execDetached({
                                command: ['whisker', 'prefs', 'set', 'barPosition', modelData.toLowerCase()]
                            })
                        }
                    }
                }
            }
        }
        SwitchOption {
            title: "Keep bar opaque";
            description: "Padding for bars\nThis will only take effect if `smallBar` is `true`."
            prefField: "keepBarOpaque"
        }
        SwitchOption {
            title: "Small bar";
            description: "Whether to keep the bar opaque or not\nIf disabled, the bar will adjust it's transparency, such as on desktop, etc."
            prefField: "smallBar"
        }
        RowLayout {
            visible: Preferences.smallBar
            ColumnLayout {
                StyledText {
                    text: "Bar Padding"
                    font.pixelSize: 16
                    color: Appearance.colors.m3on_background
                }
                StyledText {
                    text: "Padding for bars.\nThis will only take effect if `smallBar` is `true`."
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }
            Item {
                Layout.fillWidth: true
            }
            StyledTextField {
                text: Preferences.barPadding
                padding: 10
                leftPadding: undefined
                implicitWidth: 200
                inputMethodHints: Qt.ImhDigitsOnly
                onTextChanged: {
                    let num = Math.max(0, Math.min(parseInt(this.text.replace(/[^0-9.]/g, "")) || 0, Screen.width));

                    Quickshell.execDetached({
                        command: ['whisker', 'prefs', 'set', 'barPadding', num.toString()]
                    });
                }
            }
        }
        SwitchOption {
            title: "Auto hide bar";
            description: "Whether to automatically hide the bar\nTo show your bar again, move your cursor to the edge of your bar's position."
            prefField: "autoHideBar"
        }
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
            checked: Preferences[main.prefField]
            onToggled: {
                Quickshell.execDetached({
                    command: ['whisker', 'prefs', 'set', prefField, checked]
                })
            }
        }
    }
}
