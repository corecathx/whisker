import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.preferences
import qs.modules
import qs.modules.corners
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland

Scope {
    id: root
    PanelWindow {
        id: window
        // implicitWidth: 240

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "whisker:osdpanel"
        WlrLayershell.exclusionMode: ExclusionMode.Normal
        color: "transparent"

        mask: Region {
            width: window.implicitWidth
            height: bgRectangle.height
        }

        anchors.top: true
        anchors.left: true
        anchors.right: true
        margins.top: -10

        // anchors.left: Preferences.bar.position === "right"
        // margins.left: Preferences.bar.position === "right" ? -10 : 0

        // anchors.right: Preferences.bar.position !== "right"
        // margins.right: Preferences.bar.position !== "right" ? -10 : 10

        anchors.bottom: true
        margins.bottom: 10

        Item {
            id: container
            anchors.fill: parent
            ClippingRectangle {
                id: bgRectangle
                // anchors.bottom: parent.bottom
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 20
                implicitHeight: contentWrapper.height > 0 ? contentWrapper.height + 12 : 0
                implicitWidth: contentWrapper.width + 16
                color: Appearance.panel_color
                radius: Appearance.rounding.extraLarge

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: Appearance.animation.fast
                        easing.type: Appearance.animation.easing
                    }
                }
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

                RowLayout {
                    id: contentWrapper
                    anchors.centerIn: parent
                    anchors.leftMargin: visibleCount == 1 ? 8 : 6
                    Behavior on anchors.leftMargin {
                        NumberAnimation {
                            duration: Appearance.animation.fast
                            easing.type: Appearance.animation.easing
                        }
                    }
                    anchors.rightMargin: anchors.leftMargin
                    spacing: 0

                    property int visibleCount: {
                        var count = 0
                        for (var i = 0; i < children.length; i++)
                            if (children[i].visible) count++
                        return count
                    }

                    VolumeOsd { Layout.alignment: contentWrapper.visibleCount === 1 ? Qt.AlignTop : Qt.AlignRight | Qt.AlignTop }
                    BrightnessOsd { Layout.alignment: contentWrapper.visibleCount === 1 ? Qt.AlignTop : Qt.AlignLeft | Qt.AlignTop }
                }
            }
        }
    }
}
