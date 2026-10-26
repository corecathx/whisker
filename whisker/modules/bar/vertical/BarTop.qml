import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.whisker.modules
import qs.whisker.modules.bar
import qs.whisker.services
import qs.whisker.preferences

Item {
    implicitWidth: childContent.implicitWidth
    property bool inLockScreen: false

    ColumnLayout {
        id: childContent
        anchors.fill: parent
        spacing: 10

        UserIcon {
            visible: !inLockScreen 
            verticalMode: Preferences.verticalBar()

        }

        TimeLabel {
            visible: !inLockScreen
            showLabel: Hyprland.currentWorkspace.hasTilingWindow()
            verticalMode: Preferences.verticalBar()
        }

        Stats {
            verticalMode: Preferences.verticalBar()
        }
        
        Tray {
            visible: !inLockScreen 
            verticalMode: Preferences.verticalBar()
        }
    }
}
