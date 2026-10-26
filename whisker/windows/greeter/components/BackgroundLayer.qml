import QtQuick
import QtQuick.Effects

import qs.whisker.modules

Item {
    id: root

    property var images: [
        { path: Utils.getPath('assets/images/greeter/background.png'), scrollFactor: 0.2, scale: 1.2 },
        { path: Utils.getPath('assets/images/greeter/buildings.png'), scrollFactor: 0.5, scale: 1.1 },
        { path: Utils.getPath('assets/images/greeter/foreground.png'), scrollFactor: 0.8, scale: 1.06 }
    ]
    property real progress: 0
    property real scrollX: 0
    property real scrollY: 0
    Item {
        id: imageContainer
        anchors.fill: parent

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: false
            blurEnabled: true
            blur: 1
            blurMax: 32 * root.progress
            brightness: -0.1 - (0.1 * root.progress)

            Behavior on blurMax {
                NumberAnimation {
                    duration: Appearance.animation.slow
                    easing.type: Appearance.animation.easing
                }
            }

            Behavior on blur {
                NumberAnimation {
                    duration: Appearance.animation.slow
                    easing.type: Appearance.animation.easing
                }
            }

            Behavior on brightness {
                NumberAnimation {
                    duration: Appearance.animation.slow
                    easing.type: Appearance.animation.easing
                }
            }
        }

        Repeater {
            model: root.images
            delegate: Image {
                required property var modelData
                required property var index

                source: modelData.path
                sourceSize: Qt.size(root.width, root.height)
                fillMode: Image.PreserveAspectCrop
                smooth: true
                cache: true
                scale: modelData.scale + (0.08 * root.progress) * modelData.scrollFactor
                width: parent.width
                height: parent.height
                x: (root.scrollX * -1) * modelData.scrollFactor
                y: (root.scrollY * -1) * modelData.scrollFactor

                Behavior on x {
                    NumberAnimation {
                        duration: Appearance.animation.slow + (200 * index)
                        easing.type: Appearance.animation.easing
                    }
                }

                Behavior on y {
                    NumberAnimation {
                        duration: Appearance.animation.slow + (200 * index)
                        easing.type: Appearance.animation.easing
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Appearance.animation.slow - 300
                        easing.type: Appearance.animation.easing
                    }
                }
            }
        }
    }

}