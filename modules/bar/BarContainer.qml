import QtQuick
import QtQuick.Layouts
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
    SingleCorner {
        visible: !root.inLockScreen && !Preferences.bar.floating
        anchors.left: barContainer.right
        cornerType: "cubic"
        cornerHeight: root.implicitHeight
        color: !inLockScreen && Preferences.bar.keepOpaque || !inLockScreen && Hyprland.currentWorkspace.hasTilingWindow() ? Appearance.panel_color : "transparent"
        Behavior on color {
            ColorAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
        corner: 1
        transform: Scale {
            yScale: Preferences.bar.position === 'top' ? 1 : -1
            origin.y: Preferences.bar.position === 'top' ? 0 : height/2
        }
    }
    Item {
        id: barContainer
        implicitHeight: root.implicitHeight
        width: Preferences.bar.small ? screen?.width - Preferences.bar.padding * 2 - (Preferences.bar.floating ? 20 : 0) : parent?.width ?? 0
        clip: true
        Behavior on width {
            NumberAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
        anchors.horizontalCenter: parent.horizontalCenter

        StyledRectangle {
            id: panelBackground
            radius: Preferences.bar.floating ? 20 : 0
            anchors.fill: parent
            color: !inLockScreen && Preferences.bar.keepOpaque || !inLockScreen && Hyprland.currentWorkspace.hasTilingWindow() ? Appearance.panel_color : "transparent"
            Behavior on color {
                ColorAnimation {
                    duration: Appearance.animation.fast
                    easing.type: Appearance.animation.easing
                }
            }
        }

        RowLayout {
            anchors.fill: panelBackground
            ScrollControl {
                onPressed: {
                    Quickshell.execDetached({command: ['whisker', 'ipc', 'quickpanel', 'toggle']})
                }
                onScrolled: function(delta) {
                    const direction = delta > 0 ? 1 : -1
                    Brightness.set(Brightness.value + (0.05 * direction))
                }
            }
            ScrollControl {
                onPressed: {
                    Quickshell.execDetached({command: ['whisker', 'ipc', 'rightpanel', 'toggle']})
                    console.log('to be implemented')
                }

                onScrolled: function(delta) {
                    const direction = delta > 0 ? 1 : -1
                    Audio.setVolume(Audio.volume + (0.05 * direction))
                }
            }
        }

        component ScrollControl: Item {
            id: scrollCtrl

            signal pressed()
            signal scrolled(real delta)

            Layout.fillWidth: true
            Layout.fillHeight: true

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onPressed: function(mouse) {
                    scrollCtrl.pressed()
                }

                onWheel: function(wheel) {
                    scrollCtrl.scrolled(wheel.angleDelta.y)
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
                shadowOpacity: !Preferences.bar.keepOpaque && !Hyprland.currentWorkspace.hasTilingWindow()
                shadowColor: Appearance.colors.m3shadow
                shadowBlur: 1
                shadowScale: 1
            }
        }
    }
    SingleCorner {
        visible: !root.inLockScreen && !Preferences.bar.floating
        anchors.right: barContainer.left
        cornerType: "cubic"
        cornerHeight: root.implicitHeight
        color: !inLockScreen && Preferences.bar.keepOpaque || !inLockScreen && Hyprland.currentWorkspace.hasTilingWindow() ? Appearance.panel_color : "transparent"
        Behavior on color {
            ColorAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
        corner: 0
        transform: Scale {
            yScale: Preferences.bar.position === 'top' ? 1 : -1
            origin.y: Preferences.bar.position === 'top' ? 0 : height/2
        }
    }
}
