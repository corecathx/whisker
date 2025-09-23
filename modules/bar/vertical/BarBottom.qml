import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.UPower
import qs.modules
import qs.services as Serv
import qs.preferences
import qs.modules.bar

Item {
    id: root
    property bool inLockScreen: false
    
    Column {
        id: contentCol
        anchors.centerIn: parent
        spacing: 10
        
        Item {
            id: trayContainer
            width: trays.implicitWidth + 10
            height: trays.implicitHeight + 10
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: bgRect
                anchors.fill: parent
                radius: 20
                color: Appearance.colors.m3surface_container
                opacity: !Preferences.keepBarOpaque && !Serv.Hyprland.currentWorkspace.hasTilingWindow() ? 0 : 1

                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.anim_fast
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Column {
                id: trays
                anchors.centerIn: parent
                spacing: 10

                Audio {}
                NetworkTray {}
                BluetoothTray {}
            }
        }
        Battery {
            verticalMode: true
        }
        // sorry but making the battery object from horizontal bar is difficult for vertical :(
    }
    
    implicitWidth: contentCol.width
    implicitHeight: contentCol.height
}