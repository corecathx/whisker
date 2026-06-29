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
    description: "Customize the appearance and behavior of the bar."

    BaseCard {

        ColumnLayout {
            StyledText {
                text: "Position"
                font.pixelSize: 16
                color: Appearance.colors.m3on_background
            }

            StyledDropDown {
                Layout.fillWidth: true
                label: "Bar Position"
                model: ["Left", "Bottom", "Top", "Right"]

                currentIndex: {
                    const pos = Preferences.bar.position
                    const positions = ["left", "bottom", "top", "right"]
                    return positions.indexOf(pos)
                }

                onSelectedIndexChanged: (index) => {
                    const positions = ["left", "bottom", "top", "right"]
                    Quickshell.execDetached({
                        command: ["whisker", "prefs", "set", "bar.position", positions[index]]
                    })
                }
            }
        }

        SwitchOption {
            title: "Keep bar opaque"
            description: "Keep the bar fully opaque at all times. If disabled, the bar becomes transparent when appropriate, such as on the desktop."
            prefField: "bar.keepOpaque"
        }

        SwitchOption {
            title: "Small bar"
            description: "Use a compact bar. When enabled, you can adjust the padding between the bar and the edge of the screen."
            prefField: "bar.small"
        }

        SliderOption {
            visible: Preferences.bar.small && Preferences.horizontalBar()
            title: "Padding"
            description: "Set the space between the bar and the edge of the screen."
            prefField: "bar.padding"
            from: 0
            to: 500
            stepSize: 50
        }

        SwitchOption {
            title: "Auto hide bar"
            description: "Automatically hide the bar. Move your cursor to the edge of the screen where the bar is located to reveal it."
            prefField: "bar.autoHide"
        }

        SwitchOption {
            title: "Floating mode"
            description: "Display the bar detached from the edge of the screen instead of being attached to it."
            prefField: "bar.floating"
        }

        SwitchOption {
            title: "Render Overview Windows"
            description: "Show live window previews in the workspace overview."
            prefField: "misc.renderOverviewWindows"
        }
    }
}