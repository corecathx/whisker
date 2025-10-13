import QtQuick
import QtQuick.Effects
import Quickshell
import qs.modules
import qs.services
import qs.preferences
import qs.modules.corners
import qs.components
Item {
    id: root
    property bool inLockScreen: false
    implicitHeight: Appearance.barSize
    anchors.fill: parent
    SingleCorner {
        visible: !root.inLockScreen
        anchors.left: barContainer.right
        cornerType: "cubic"
        cornerHeight: root.implicitHeight
        color: !inLockScreen && Preferences.keepBarOpaque || !inLockScreen && Hyprland.currentWorkspace.hasTilingWindow() ? Appearance.panel_color : "transparent"
        Behavior on color {
            ColorAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
        corner: 1
        transform: Scale {
            yScale: Preferences.barPosition === 'top' ? 1 : -1
            origin.y: Preferences.barPosition === 'top' ? 0 : height/2
        }
    }
    Item {
        id: barContainer
        implicitHeight: root.implicitHeight
        width: Preferences.smallBar ? screen?.width - Preferences.barPadding * 2 : parent?.width ?? 0
        clip: true
        Behavior on width {
            NumberAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: panelBackground
            anchors.fill: parent
            color: !inLockScreen && Preferences.keepBarOpaque || !inLockScreen && Hyprland.currentWorkspace.hasTilingWindow() ? Appearance.panel_color : "transparent"
            Behavior on color {
                ColorAnimation {
                    duration: Appearance.animation.fast
                    easing.type: Appearance.animation.easing
                }
            }
        }

        Item {
            anchors.fill: parent
            BarMiddle {
                id:barMid
                visible: !root.inLockScreen
            }
            BarLeft {
                inLockScreen: root.inLockScreen
                anchors.left: parent.left
                anchors.leftMargin: 40
                anchors.verticalCenter: parent.verticalCenter
            }

            BarRight {
                inLockScreen: root.inLockScreen
                anchors.right: parent.right
                anchors.rightMargin: 40
                anchors.verticalCenter: parent.verticalCenter
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
    SingleCorner {
        visible: !root.inLockScreen
        anchors.right: barContainer.left
        cornerType: "cubic"
        cornerHeight: root.implicitHeight
        color: !inLockScreen && Preferences.keepBarOpaque || !inLockScreen && Hyprland.currentWorkspace.hasTilingWindow() ? Appearance.panel_color : "transparent"
        Behavior on color {
            ColorAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
        corner: 0
        transform: Scale {
            yScale: Preferences.barPosition === 'top' ? 1 : -1
            origin.y: Preferences.barPosition === 'top' ? 0 : height/2
        }
    }
}
