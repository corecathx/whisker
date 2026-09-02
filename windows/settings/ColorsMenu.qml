import Quickshell.Widgets
import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import qs.modules
import qs.components
import qs.preferences


BaseMenu {
    title: "Color Scheme"
    description: "Adjust how Whisker looks like to your preference."
    BaseCard {
        ColorSchemePreview {}
        Flickable {
            id: schemeFlick
            anchors.left: parent.left
            anchors.right: parent.right
            height: 150
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.HorizontalFlick
            contentWidth: rowContent.childrenRect.width
            contentHeight: rowContent.childrenRect.height

            RowLayout {
                id: rowContent
                spacing: 10
                Repeater {
                    model: ['content', 'expressive', 'fidelity', 'fruit-salad', 'monochrome', 'neutral', 'rainbow', 'tonal-spot']
                    delegate: ColorSchemeCard { schemeName: modelData }
                }
            }
        }
    }

    BaseCard {
        SectionTitle { icon: "build"; text: "Configuration" }

        SwitchOption {
            id: smartSwitch
            title: "Smart theme"
            description: "Automatically choose light or dark colors from the wallpaper."
            prefField: "theme.smart"
        }

        SwitchOption {
            title: "Dark mode"
            description: "Whether to use dark color schemes."
            prefField: "theme.dark"
            visible: !smartSwitch.checked
        }

        SliderOption {
            title: "Contrast"
            description: "Set how contrast is the colors.\n(Colors need to be applied manually)"
            prefField: "theme.contrast"
            from: -1
            to: 1
            stepSize: 0.2
            visible: !smartSwitch.checked
        }
    }
}
