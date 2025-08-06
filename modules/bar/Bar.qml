import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules
import qs.preferences
import QtQuick.Effects

Scope {
    id: root
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            WlrLayershell.layer: WlrLayer.Top
            color: "transparent"

            anchors {
                top: Preferences.barPosition === 'top'
                bottom: Preferences.barPosition === 'bottom'
                left: true
                right: true
            }

            implicitHeight: item.implicitHeight

            BarContainer {
                id: item
            }
        }
    }
}
