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
        color: Appearance.colors.m3primary_container
        radius: 100
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: root.fill * parent.width
            color: Appearance.colors.m3primary
        }
    }
}