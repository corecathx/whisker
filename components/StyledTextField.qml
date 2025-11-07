import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.modules

TextField {
    id: control

    property string icon: ""
    property color iconColor: Appearance.colors.m3on_surface
    property string placeholder: "Type here..."
    property real iconSize: 25

    property alias radius: background.radius
    property alias topLeftRadius: background.topLeftRadius
    property alias topRightRadius: background.topRightRadius
    property alias bottomLeftRadius: background.bottomLeftRadius
    property alias bottomRightRadius: background.bottomRightRadius
    property color backgroundColor: Appearance.colors.m3surface_container

    property int fieldPadding: 20
    property int iconSpacing: 15
    property int iconMargin: 20

    width: parent ? parent.width - 40 : 300
    placeholderText: placeholder
    font.pixelSize: 16
    padding: fieldPadding
    leftPadding: icon !== "" ? iconSize + iconSpacing + iconMargin : fieldPadding

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
        id: background
        radius: 20
        color: control.backgroundColor
        border.width: 0
        Behavior on color { ColorAnimation { duration: 180 } }
    }

    MaterialIcon {
        icon: control.icon
        anchors.left: parent.left
        anchors.leftMargin: control.icon !== "" ? control.iconMargin : 0
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: control.iconSize
        color: control.iconColor
        visible: control.icon !== ""
    }
}
