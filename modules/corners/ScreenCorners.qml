import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.modules
import qs.modules.overlays
import qs.preferences

PanelWindow {
    anchors {
        top: true
        left: true
        bottom: true
        right: true
    }

    color: "transparent"

    mask: Region {}
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: Preferences.bar.small || Preferences.bar.floating ? ExclusionMode.Ignore : ExclusionMode.Auto

    property int shadowSize: 20
    property color shadowColor: Colors.opacify(Appearance.colors.m3shadow, 0.5)
    readonly property var shadowSides: [
        { anchors: { top: true, left: true, right: true }, height: shadowSize, horizontal: false, reverse: false },   // top
        { anchors: { bottom: true, left: true, right: true }, height: shadowSize, horizontal: false, reverse: true }, // bottom
        { anchors: { top: true, bottom: true, left: true }, width: shadowSize, horizontal: true, reverse: false },    // left
        { anchors: { top: true, bottom: true, right: true }, width: shadowSize, horizontal: true, reverse: true }     // right
    ]

    Repeater {
        model: []//shadowSides

        Item {
            anchors {
                top: modelData.anchors.top ? parent.top : undefined
                bottom: modelData.anchors.bottom ? parent.bottom : undefined
                left: modelData.anchors.left ? parent.left : undefined
                right: modelData.anchors.right ? parent.right : undefined
            }
            width: modelData.width || parent.width
            height: modelData.height || parent.height

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    var g
                    if (modelData.horizontal) {
                        g = ctx.createLinearGradient(
                            modelData.reverse ? width : 0, 0,
                            modelData.reverse ? 0 : width, 0
                        )
                    } else {
                        g = ctx.createLinearGradient(
                            0, modelData.reverse ? height : 0,
                            0, modelData.reverse ? 0 : height
                        )
                    }
                    g.addColorStop(0, shadowColor)
                    g.addColorStop(0.9, "transparent")
                    ctx.fillStyle = g
                    ctx.fillRect(0, 0, width, height)
                }

                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
            }
        }
    }

    Corners {
        cornerType: "inverted"
        cornerHeight: 20
        color: Preferences.bar.small || Preferences.bar.floating ? "black" : Appearance.colors.m3surface
        corners: [0,1,2,3]
    }
}
