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
                top: Preferences.barPosition === 'top' || Preferences.barPosition === 'left' || Preferences.barPosition === 'right'
                bottom: Preferences.barPosition === 'bottom' || Preferences.barPosition === 'left' || Preferences.barPosition === 'right'
                left: Preferences.barPosition === 'left' || Preferences.barPosition === 'top' || Preferences.barPosition === 'bottom'
                right: Preferences.barPosition === 'right' || Preferences.barPosition === 'top' || Preferences.barPosition === 'bottom'
            }

            implicitHeight: Preferences.horizontalBar() ? item.implicitHeight : 0
            implicitWidth: Preferences.verticalBar() ? item.implicitWidth : 0

            BarContainer {
                id: item
            }
        }
    }
}
