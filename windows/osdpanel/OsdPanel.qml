import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.preferences
import qs.modules
import qs.modules.corners
import Quickshell
import Quickshell.Wayland

Scope {
    id: root
    PanelWindow {
        id: window
        implicitWidth: 440

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "whisker:osdpanel"
        WlrLayershell.exclusionMode: ExclusionMode.Normal
        color: "transparent"

        mask: Region {
            width: window.implicitWidth
            height: bgRectangle.height
        }

        anchors.top: true
        anchors.left: Preferences.barPosition === "right"
        anchors.right: Preferences.barPosition !== "right"
        anchors.bottom: true

        Item {
            id: container
            anchors.fill: parent

            Rectangle {
                id: bgRectangle
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.leftMargin: Preferences.barPosition === "right" ? 0 : 20
                anchors.rightMargin: Preferences.barPosition === "right" ? 20 : 0
                implicitHeight: contentWrapper.height > 0 ? contentWrapper.height + 20 : 0
                color: Appearance.panel_color
                radius: 0
                bottomRightRadius: Preferences.barPosition === 'right' ? 20 : 0
                bottomLeftRadius: Preferences.barPosition !== 'right' ? 20 : 0

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: Appearance.anim_fast
                        easing.type: Easing.OutCubic
                    }
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowOpacity: 1
                    shadowColor: Appearance.colors.m3shadow
                    shadowBlur: 1
                    shadowScale: 1
                }

                SingleCorner {
                    visible: Preferences.barPosition !== "right"
                    cornerType: "inverted"
                    cornerHeight: Math.min(bgRectangle.implicitHeight, 20)
                    cornerWidth: 20
                    color: Appearance.panel_color
                    corner: 0
                    anchors.right: bgRectangle.left
                    anchors.top: bgRectangle.top
                }

                SingleCorner {
                    visible: Preferences.barPosition !== "right"
                    cornerType: "inverted"
                    cornerHeight: Math.min(bgRectangle.implicitHeight, 20)
                    cornerWidth: 20
                    color: Appearance.panel_color
                    corner: 0
                    anchors.right: bgRectangle.right
                    anchors.top: bgRectangle.bottom
                }

                SingleCorner {
                    visible: Preferences.barPosition === "right"
                    cornerType: "inverted"
                    cornerHeight: Math.min(bgRectangle.implicitHeight, 20)
                    cornerWidth: 20
                    color: Appearance.panel_color
                    corner: 1
                    anchors.left: bgRectangle.right
                    anchors.top: bgRectangle.top
                }

                SingleCorner {
                    visible: Preferences.barPosition === "right"
                    cornerType: "inverted"
                    cornerHeight: Math.min(bgRectangle.implicitHeight, 20)
                    cornerWidth: 20
                    color: Appearance.panel_color
                    corner: 1
                    anchors.left: bgRectangle.left
                    anchors.top: bgRectangle.bottom
                }

                ColumnLayout {
                    id: contentWrapper
                    anchors.top: bgRectangle.top
                    anchors.left: bgRectangle.left
                    anchors.right: bgRectangle.right
                    anchors.topMargin: 10
                    VolumeOsd {}
                }
            }
        }
    }
}
