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


        RowLayout {
            ColumnLayout {
                StyledText {
                    text: "Dark mode"
                    font.pixelSize: 16
                    color: Appearance.colors.m3on_background
                }
                StyledText {
                    text: "Whether to use dark color schemes."
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }
            Item {
                Layout.fillWidth: true
            }
            StyledSwitch {
                checked: Preferences.darkMode
                onToggled: {
                    Quickshell.execDetached({
                        command: ['whisker', 'prefs', 'set', 'darkMode', checked]
                    })
                }
            }
        }
    }
}
