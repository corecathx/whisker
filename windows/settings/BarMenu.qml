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
        // StyledText {
        //     text: "Bar"
        //     font.pixelSize: 20
        //     font.bold: true
        //     color: Appearance.colors.m3on_background
        // }

        ColumnLayout {
            StyledText {
                text: "Position"
                font.pixelSize: 16
                color: Appearance.colors.m3on_background
            }

            StyledDropDown {
                Layout.fillWidth: true
                label: "Bar Position"
                model: ['Left', 'Bottom', 'Top', 'Right']
                currentIndex: {
                    const pos = Preferences.bar.position
                    const positions = ['left', 'bottom', 'top', 'right']
                    return positions.indexOf(pos)
                }

                onSelectedIndexChanged: (index) => {
                    const positions = ['left', 'bottom', 'top', 'right']
                    Quickshell.execDetached({
                        command: ['whisker', 'prefs', 'set', 'bar.position', positions[index]]
                    })
                }
            }
        }

        SwitchOption {
            title: "Keep bar opaque"
            description: "Padding for bars\nThis will only take effect if `smallBar` is `true`."
            prefField: "bar.keepOpaque"
        }

        SwitchOption {
            title: "Small bar"
            description: "Whether to keep the bar opaque or not\nIf disabled, the bar will adjust it's transparency, such as on desktop, etc."
            prefField: "bar.small"
        }

        RowLayout {
            visible: Preferences.bar.small
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
                text: Preferences.bar.padding
                padding: 10
                leftPadding: undefined
                implicitWidth: 200
                inputMethodHints: Qt.ImhDigitsOnly
                onTextChanged: {
                    let num = Math.max(0, Math.min(parseInt(this.text.replace(/[^0-9.]/g, "")) || 0, Screen.width));

                    Quickshell.execDetached({
                        command: ['whisker', 'prefs', 'set', 'bar.padding', num.toString()]
                    });
                }
            }
        }

        SwitchOption {
            title: "Auto hide bar"
            description: "Whether to automatically hide the bar\nTo show your bar again, move your cursor to the edge of your bar's position."
            prefField: "bar.autoHide"
        }
        SwitchOption { title: "Render Overview Windows"; description: "Render window previews in the overview"; prefField: "misc.renderOverviewWindows" }

    }

    component SwitchOption: RowLayout {
        id: main
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
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
                })
            }
        }
    }
}
