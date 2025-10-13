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
                        onClicked: {
                            Quickshell.execDetached({
                                command: ['whisker', 'prefs', 'set', 'barPosition', modelData.toLowerCase()]
                            })
                        }
                    }
                }
            }
        }
        RowLayout {
            ColumnLayout {
                StyledText {
                    text: "Keep bar opaque"
                    font.pixelSize: 16
                    color: Appearance.colors.m3on_background
                }
                StyledText {
                    text: "Whether to keep the bar opaque or not\nIf disabled, the bar will adjust it's transparency, such as on desktop, etc."
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }
            Item {
                Layout.fillWidth: true
            }
            StyledSwitch {
                checked: Preferences.keepBarOpaque
                onToggled: {
                    Quickshell.execDetached({
                        command: ['whisker', 'prefs', 'set', 'keepBarOpaque', checked]
                    })
                }
            }
        }
        RowLayout {
            ColumnLayout {
                StyledText {
                    text: "Small bar"
                    font.pixelSize: 16
                    color: Appearance.colors.m3on_background
                }
                StyledText {
                    text: "Whether to use small bar layout.\nThis has no effect on Left and Right bar layout."
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }
            Item {
                Layout.fillWidth: true
            }
            StyledSwitch {
                checked: Preferences.smallBar
                onToggled: {
                    Quickshell.execDetached({
                        command: ['whisker', 'prefs', 'set', 'smallBar', checked]
                    })
                }
            }
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
    }
}
