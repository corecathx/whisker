// Originally CornerThingy mk2 by SealEgg
// Modified by CoreCat so it only shows one corner instead of all fours.

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    // "cubic", "rounded", or "inverted"
    property string cornerType: "cubic"
    property int cornerHeight: 30
    property int cornerWidth: cornerHeight
    property color color: "#000000"

    // either one of these 0 = top-right, 1 = top-left, 2 = bottom-left, 3 = bottom-right
    property int corner: 0

    // Cubic Corner
    Item {
        anchors.fill: parent
        visible: root.cornerType === "cubic"

        Shape {
            width: root.cornerWidth
            height: root.cornerHeight
            asynchronous: true
            preferredRendererType: Shape.CurveRenderer
            antialiasing: true

            Component.onCompleted: setAnchors(this)

            ShapePath {
                fillColor: root.color
                strokeWidth: 0
                startX: root.corner % 2 !== 0 ? root.cornerWidth : 0
                startY: 0

                PathCubic {
                    x: root.corner % 2 === 0 ? root.cornerWidth : 0
                    y: root.cornerHeight
                    relativeControl1X: root.corner % 2 === 0 ? root.cornerWidth / 2 : -root.cornerWidth / 2
                    relativeControl1Y: 0
                    relativeControl2X: root.corner % 2 === 0 ? root.cornerWidth / 2 : -root.cornerWidth / 2
                    relativeControl2Y: root.cornerHeight
                }
                PathLine {
                    x: root.corner % 2 === 0 ? root.cornerWidth : 0
                    y: 0
                }
            }

            transform: Rotation {
                origin.x: root.cornerWidth / 2
                origin.y: root.cornerHeight / 2
                angle: root.corner > 1 ? 180 : 0
            }
        }
    }

    // Rounded Corner
    Item {
        anchors.fill: parent
        visible: root.cornerType === "rounded"

        Shape {
            width: root.cornerWidth
            height: root.cornerHeight
            asynchronous: true
            preferredRendererType: Shape.CurveRenderer
            antialiasing: true

            Component.onCompleted: setAnchors(this)

            ShapePath {
                fillColor: root.color
                strokeWidth: -1
                startX: 0; startY: 0

                PathLine { x: root.cornerWidth; y: 0 }
                PathLine { x: root.cornerWidth; y: root.cornerHeight }
                PathArc  { x: 0; y: 0; radiusX: root.cornerWidth; radiusY: root.cornerHeight }
            }

            transform: Rotation {
                origin.x: root.cornerWidth / 2
                origin.y: root.cornerHeight / 2
                angle: root.corner * -90
            }
        }
    }

    // Inverted Corner
    Item {
        anchors.fill: parent
        visible: root.cornerType === "inverted"

        Shape {
            width: root.cornerWidth
            height: root.cornerHeight
            asynchronous: true
            preferredRendererType: Shape.CurveRenderer
            antialiasing: true

            Component.onCompleted: setAnchors(this)

            ShapePath {
                fillColor: root.color
                strokeWidth: -1
                startX: 0; startY: 0

                PathArc  { x: root.cornerWidth; y: root.cornerHeight; radiusX: root.cornerWidth; radiusY: root.cornerHeight }
                PathLine { x: root.cornerWidth; y: 0 }
            }

            transform: Rotation {
                origin.x: root.cornerWidth / 2
                origin.y: root.cornerHeight / 2
                angle: root.corner * -90
            }
        }
    }

    function setAnchors(item) {
        item.anchors.right = (root.corner === 0 || root.corner === 3) ? root.right : undefined
        item.anchors.left = (root.corner === 1 || root.corner === 2) ? root.left : undefined
        item.anchors.top = (root.corner <= 1) ? root.top : undefined
        item.anchors.bottom = (root.corner > 1) ? root.bottom : undefined
    }
}
