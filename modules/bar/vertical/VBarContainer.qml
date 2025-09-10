import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs.modules
import qs.modules.bar
import qs.services
import qs.preferences
import qs.modules.corners
import qs.components

Item {
    id: root
    property bool inLockScreen: false

    implicitWidth: 60
    implicitHeight: parent ? parent.height : 0
    anchors.fill: parent

    Item {
        id: barContainer
        implicitHeight: root.implicitHeight
        anchors.fill: parent
        clip: true

        Rectangle {
            anchors.fill: parent
            color: !inLockScreen && Preferences.keepBarOpaque || !inLockScreen && Hyprland.currentWorkspace.hasTilingWindow() ? Appearance.panel_color : "transparent"
            Behavior on color { ColorAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic } }
        }

        Item {
            anchors.fill: parent
            Item {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: {
                    return (root.implicitWidth - wawa.width) * 0.5
                }
                anchors.topMargin: 40
                BarTop {
                    id: wawa
                }
            }
            Item {
                anchors.fill: parent
                BarMiddle {
                    verticalMode: Preferences.verticalBar()
                }
            }
            Item {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottomMargin: 40
                
                BarBottom {
                    id: btm
                    anchors.centerIn: parent
                }
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowOpacity: !Preferences.keepBarOpaque && !Hyprland.currentWorkspace.hasTilingWindow()
            shadowColor: Appearance.colors.m3shadow
            shadowBlur: 1
            shadowScale: 1
        }
    }
}
