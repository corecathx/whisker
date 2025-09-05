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
        implicitWidth: 450 + 40
        Behavior on implicitHeight {
            NumberAnimation {
                duration: Appearance.anim_fast;
                easing.type: Easing.OutCubic
            }
        }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "whisker:osdpanel"
        WlrLayershell.exclusionMode: ExclusionMode.Normal
        color: "transparent"
        anchors.top: true
        anchors.bottom: true

        anchors.right: true
        margins.right: Preferences.smallBar ? Preferences.barPadding + 20 : 0

        mask: Region {
            width: window.implicitWidth
            height: bgRectangle.height
        }

        Item {
            id: container
            implicitHeight: bgRectangle.implicitHeight
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: Preferences.barPosition === "top" ? parent.top : undefined
            anchors.bottom: Preferences.barPosition === "bottom" ? parent.bottom : undefined
            anchors.topMargin: Preferences.barPosition !== "top" ? 20 : 0
            anchors.bottomMargin: Preferences.barPosition !== "bottom" ? 20 : 0
            Rectangle {
                id: bgRectangle
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowOpacity: 1
                    shadowColor: Appearance.colors.m3shadow
                    shadowBlur: 1
                    shadowScale: 1
                }
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: Preferences.barPosition === 'top' ? parent.top : undefined
                anchors.bottom: {
                    console.log(Preferences.barPosition.toLowerCase() === 'bottom' ? "You should get bottom" : "you sould get undefined")
                    return Preferences.barPosition.toLowerCase() === 'bottom' ? parent.bottom : undefined
                }
                anchors.leftMargin: 20
                anchors.rightMargin: !Preferences.smallBar ? 0 : 20
                topLeftRadius: Preferences.barPosition === "bottom" ? 20 : 0
                topRightRadius: Preferences.barPosition === "bottom" && Preferences.smallBar ? 20 : 0
                bottomLeftRadius: Preferences.barPosition === "bottom" ? 0 : 20
                bottomRightRadius: Preferences.barPosition === "top" && Preferences.smallBar ? 20 : 0
                color: Appearance.panel_color
                implicitHeight: contentWrapper.height > 0 ? contentWrapper.height + 20 : 0
                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: Appearance.anim_fast;
                        easing.type: Easing.OutCubic;
                    }
                }
                SingleCorner {
                    cornerType: "inverted"
                    cornerHeight: Math.min(bgRectangle.implicitHeight, 20)
                    cornerWidth: 20
                    color: Appearance.panel_color
                    corner: Preferences.barPosition === "top" ? 0 : 3
                    anchors.right: bgRectangle.left
                    anchors.top: Preferences.barPosition === "top" ? bgRectangle.top : undefined
                    anchors.bottom: Preferences.barPosition === "bottom" ? bgRectangle.bottom : undefined
                }
                SingleCorner {
                    id: corner
                    cornerType: "inverted"
                    cornerHeight: Math.min(bgRectangle.implicitHeight, 20)
                    cornerWidth: 20
                    color: Appearance.panel_color
                    corner: Preferences.barPosition === "top"
                            ? (Preferences.smallBar ? 1 : 0)
                            : 2

                    anchors.right: Preferences.barPosition === "top"
                            ? (Preferences.smallBar ? undefined : bgRectangle.right)
                            : (Preferences.smallBar ? undefined : bgRectangle.right)
                    anchors.left: Preferences.barPosition === "top"
                            ? (Preferences.smallBar ? bgRectangle.right : undefined)
                            : bgRectangle.right
                    anchors.bottom: Preferences.barPosition === "bottom"
                            ? (Preferences.smallBar ? bgRectangle.bottom : bgRectangle.top)
                            : undefined
                    anchors.top: Preferences.barPosition === "top"
                            ? (Preferences.smallBar ? bgRectangle.top : bgRectangle.bottom)
                            : undefined
                }

                // all osds
                ColumnLayout {
                    id: contentWrapper
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 10
                    VolumeOsd {}
                }
            }
        }
    }
}