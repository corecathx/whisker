import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules
import qs.preferences
import qs.modules.bar.vertical
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
                top: Preferences.barPosition === 'top' || Preferences.verticalBar()
                bottom: Preferences.barPosition === 'bottom'|| Preferences.verticalBar()
                left: Preferences.barPosition === 'left' || Preferences.horizontalBar()
                right: Preferences.barPosition === 'right' || Preferences.horizontalBar()
            }

            implicitHeight: barLoader.item ? barLoader.item.implicitHeight : 0
            implicitWidth: barLoader.item ? barLoader.item.implicitWidth : 0

            Loader {
                id: barLoader
                anchors.fill: parent
                sourceComponent: Preferences.verticalBar() ? barVertical : barHorizontal
            }

            Component { id: barHorizontal; BarContainer { } }
            Component { id: barVertical; VBarContainer { } }
        }
    }
}
