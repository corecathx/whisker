import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.modules

TextField {
    id: control

    property string icon: ""
    property color iconColor: Appearance.colors.m3on_surface
    property string placeholder: "Type here..."
    property real iconSize: icon === "" ? 0 : 25
    property real radius: 20
    property color backgroundColor: Appearance.colors.m3surface_container

    width: parent ? parent.width - 40 : 300
    placeholderText: placeholder
    font.pixelSize: 16
    padding: 20
    leftPadding: icon !== "" ? iconSize + 35 : 0
    color: Appearance.colors.m3on_surface
    placeholderTextColor: Colors.opacify(Appearance.colors.m3on_surface, 0.4)
    cursorVisible: control.focus

    cursorDelegate: Rectangle {
        width: 2
        radius: 1
        color: Appearance.colors.m3on_surface
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { from: 1; to: 0; duration: 2000; easing.type: Appearance.animation.easing }
            NumberAnimation { from: 0; to: 1; duration: 2000; easing.type: Appearance.animation.easing }
        }
    }

    background: Rectangle {
        id: bg
        radius: control.radius
        color: control.backgroundColor
        border.width: 0

        Behavior on color { ColorAnimation { duration: 180 } }
    }


    MaterialIcon {
        icon: control.icon
        anchors.left: parent.left
        anchors.leftMargin: control.icon !== "" ? 20 : 0
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: control.iconSize
        color: control.iconColor
        visible: control.icon !== ""
    }
}
