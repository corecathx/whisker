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
        margins.top: -10

        anchors.left: Preferences.bar.position === "right"
        margins.left: Preferences.bar.position === "right" ? -10 : 0

        anchors.right: Preferences.bar.position !== "right"
        margins.right: Preferences.bar.position !== "right" ? -10 : 0

        anchors.bottom: true
        margins.bottom: 10

        Item {
            id: container
            anchors.fill: parent

            Rectangle {
                id: bgRectangle
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.margins: 20
                implicitHeight: contentWrapper.height > 0 ? contentWrapper.height + 20 : 0
                color: Appearance.panel_color
                radius: 20

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: Appearance.animation.fast
                        easing.type: Appearance.animation.easing
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

                ColumnLayout {
                    id: contentWrapper
                    anchors.top: bgRectangle.top
                    anchors.left: bgRectangle.left
                    anchors.right: bgRectangle.right
                    anchors.topMargin: 10
                    VolumeOsd {}
                    BrightnessOsd {}
                }
            }
        }
    }
}
