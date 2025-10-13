import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules
Item {
    id:root
    property real fill: 0
    Layout.fillWidth: true
    height: 20
    ClippingRectangle {
        anchors.fill: parent
        color: Colors.opacify(Appearance.colors.m3on_background, 0.1)
        radius: 100
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: root.fill * parent.width
            radius: 100
            color: Appearance.colors.m3primary

            Behavior on width {
                NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
            }

            Behavior on color {
                ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
            }
        }
    }
}
