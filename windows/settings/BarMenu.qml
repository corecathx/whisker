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

        SliderOption {
            visible: Preferences.bar.small && Preferences.horizontalBar()
            title: "Padding"
            description: "Set how large / small is the gap between the bar and your screen."
            prefField: "bar.padding"
            from: 0
            to: 500
            stepSize: 50
        }

        SwitchOption {
            title: "Auto hide bar"
            description: "Whether to automatically hide the bar\nTo show your bar again, move your cursor to the edge of your bar's position."
            prefField: "bar.autoHide"
        }
        SwitchOption {
            title: "Floating mode"
            description: "If enabled, the bar won't appear attached to edge of your screen."
            prefField: "bar.floating"
        }

        SwitchOption { title: "Render Overview Windows"; description: "Render window previews in the overview"; prefField: "misc.renderOverviewWindows" }

    }

}
