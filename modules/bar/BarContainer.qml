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

    implicitHeight: Preferences.horizontalBar() ? 50 : 0
    implicitWidth: Preferences.verticalBar() ? 50 : 0

    anchors.fill: parent

    Item {
        id: barContainer
        height: Preferences.verticalBar()
                  ? (Preferences.smallBar ? screen?.height - Preferences.barPadding * 2 : parent?.height ?? 0)
                  : root.implicitHeight
        width: Preferences.horizontalBar()
                  ? (Preferences.smallBar ? screen?.width - Preferences.barPadding * 2 : parent?.width ?? 0)
                  : root.implicitWidth
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: Appearance.anim_medium
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Appearance.anim_medium
                easing.type: Easing.OutCubic
            }
        }

        anchors {
            // Horizontal bar → anchored top/bottom
            top: Preferences.barPosition === "top" ? parent.top : undefined
            bottom: Preferences.barPosition === "bottom" ? parent.bottom : undefined
            left: Preferences.barPosition === "left" ? parent.left : undefined
            right: Preferences.barPosition === "right" ? parent.right : undefined

            // If smallBar → center the bar
            horizontalCenter: Preferences.horizontalBar() && Preferences.smallBar ? parent.horizontalCenter : undefined
            verticalCenter: Preferences.verticalBar() && Preferences.smallBar ? parent.verticalCenter : undefined
        }

        Rectangle {
            id: panelBackground
            anchors.fill: parent
            color: !inLockScreen && Hyprland.currentWorkspace.hasTilingWindow()
                     ? Appearance.panel_color
                     : "transparent"
            Behavior on color {
                ColorAnimation {
                    duration: Appearance.anim_medium
                    easing.type: Easing.OutCubic
                }
            }
        }

        CavaVisualizer {
            spacing: 8
            position: Preferences.barPosition === "bottom" ? "bottom" : ""
            multiplier: 0.25
            visible: Players.active && (!inLockScreen && Hyprland.currentWorkspace.hasTilingWindow())
            anchors {
                fill: parent
                leftMargin: Preferences.horizontalBar() && !Preferences.smallBar ? 40 : 0
                rightMargin: Preferences.horizontalBar() && !Preferences.smallBar ? 40 : 0
                topMargin: Preferences.verticalBar() && !Preferences.smallBar ? 40 : 0
                bottomMargin: Preferences.verticalBar() && !Preferences.smallBar ? 40 : 0
            }
        }

        Item {
            anchors.fill: parent

            // Left/Top section
            BarLeft {
                inLockScreen: root.inLockScreen
                anchors {
                    left: Preferences.horizontalBar() ? parent.left : undefined
                    top: Preferences.verticalBar() ? parent.top : undefined
                    verticalCenter: Preferences.horizontalBar() ? parent.verticalCenter : undefined
                    leftMargin: Preferences.horizontalBar() ? 40 : 0
                    topMargin: Preferences.verticalBar() ? 40 : 0
                }
                width: Preferences.verticalBar() ? parent.width : undefined
            }

            // Right/Bottom section
            BarRight {
                inLockScreen: root.inLockScreen
                anchors {
                    right: Preferences.horizontalBar() ? parent.right : undefined
                    bottom: Preferences.verticalBar() ? parent.bottom : undefined
                    verticalCenter: Preferences.horizontalBar() ? parent.verticalCenter : undefined
                    rightMargin: Preferences.horizontalBar() ? 40 : 0
                    bottomMargin: Preferences.verticalBar() ? 40 : 0
                }
                width: Preferences.verticalBar() ? parent.width : undefined
            }

            // Middle section
            BarMiddle {
                visible: !root.inLockScreen
                anchors {
                    horizontalCenter: Preferences.horizontalBar() ? parent.horizontalCenter : undefined
                    verticalCenter: Preferences.verticalBar() ? parent.verticalCenter : undefined
                }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowOpacity: 1
                shadowColor: Appearance.colors.m3shadow
                shadowBlur: 2
                shadowScale: 1
            }
        }
    }
}
