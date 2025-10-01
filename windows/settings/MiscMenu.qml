import qs.modules
import qs.components
import qs.preferences

import QtQuick
import QtQuick.Layouts

import Quickshell
BaseMenu {
    title: "Misc"
    description: "Settings that went uncategorized."

    BaseCard {
        RowLayout {
            ColumnLayout {
                Text {
                    text: "Visualizers"
                    font.pixelSize: 16
                    color: Appearance.colors.m3on_background
                }
                Text {
                    text: "Whether to display visualizer on the Shell.\nSetting this to `false` would disable every visualizer on the shell."
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }
            Item {
                Layout.fillWidth: true
            }
            StyledSwitch {
                checked: Preferences.cavaEnabled
                onToggled: {
                    Quickshell.execDetached({
                        command: ['whisker', 'prefs', 'set', 'cavaEnabled', checked]
                    })
                }
            }
        }
    }
}