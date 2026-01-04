import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules
Item {
    id:root
    property real fill: 0
    property real gap: 6
    property real gapRadius: 4;
    Layout.fillWidth: true
    height: 20
    Item {
        anchors.fill: parent
        // color: Colors.opacify(Appearance.colors.m3on_background, 0.1)
        // radius: 100
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: root.fill * parent.width - (root.gap / 2)
            radius: 100
            color: Appearance.colors.m3primary
            topRightRadius: root.gapRadius
            bottomRightRadius: root.gapRadius
            Behavior on width {
                NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
            }

            Behavior on color {
                ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
            }
        }
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: (1-root.fill) * parent.width - (root.gap / 2)
            radius: 100
            color: Colors.opacify(Appearance.colors.m3primary, 0.1)
            topLeftRadius: root.gapRadius
            bottomLeftRadius: root.gapRadius

            Behavior on width {
                NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
            }

            Behavior on color {
                ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
            }
        }
    }
}
