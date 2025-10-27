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
            title: "Visualizers";
            description: "Whether to display visualizer on the shell.\nSetting this to `false` would disable every visualizer on the shell."
            prefField: "cavaEnabled"
        }
        SwitchOption {
            title: "Render Overview Windows";
            description: "Whether to render overview windows."
            prefField: "renderOverviewWindows"
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
