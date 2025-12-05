import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.modules
TextField {
    id: control
    property string icon: ""
    property color iconColor: Appearance.colors.m3on_surface_variant
    property string placeholder: ""
    property real iconSize: 24
    property alias radius: bg.radius
    property alias topLeftRadius: bg.topLeftRadius
    property alias topRightRadius: bg.topRightRadius
    property alias bottomLeftRadius: bg.bottomLeftRadius
    property alias bottomRightRadius: bg.bottomRightRadius
    property color backgroundColor: filled
        ? Appearance.colors.m3surface_container_high
        : "transparent"
    property int fieldPadding: 20
    property int iconSpacing: 14
    property int iconMargin: 20
    property bool filled: true
    width: parent ? parent.width - 40 : 300
    placeholderText: placeholder
    leftPadding: icon !== "" ? iconSize + iconSpacing + iconMargin : fieldPadding
    padding: fieldPadding
    verticalAlignment: TextInput.AlignVCenter
    color: Appearance.colors.m3on_surface
    placeholderTextColor: Appearance.colors.m3on_surface_variant
    font.family: "Outfit"
    font.pixelSize: 14
    cursorVisible: control.focus
    cursorDelegate: Rectangle {
        width: 2
        color: Appearance.colors.m3primary
        visible: control.focus
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: control.focus
            NumberAnimation { from: 1; to: 0; duration: Appearance.animation.slow*2 }
            NumberAnimation { from: 0; to: 1; duration: Appearance.animation.slow*2 }
        }
    }
    background: Item {

        Rectangle {
            id: bg
            anchors.fill: parent
            radius: 4
            color: control.backgroundColor
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: {
                    if (control.activeFocus)
                        return Colors.opacify(Appearance.colors.m3primary, 0.08)
                    if (control.hovered)
                        return Colors.opacify(Appearance.colors.m3on_surface, 0.08)
                    return "transparent"
                }
                Behavior on color { ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing; } }
            }
        }
        Rectangle {
            id: indicator
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: control.activeFocus ? 2 : 1
            color: {
                if (control.activeFocus)
                    return Appearance.colors.m3primary
                if (control.hovered)
                    return Appearance.colors.m3on_surface
                return Appearance.colors.m3on_surface_variant
            }
            visible: filled
            Behavior on height { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing; } }
            Behavior on color { ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing; } }
        }
        Rectangle {
            id: outline
            anchors.fill: parent
            radius: bg.radius
            color: "transparent"
            border.width: control.activeFocus ? 2 : 1
            border.color: {
                if (control.activeFocus)
                    return Appearance.colors.m3primary
                if (control.hovered)
                    return Appearance.colors.m3on_surface
                return Appearance.colors.m3outline
            }
            visible: !filled
            Behavior on border.width { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing; } }
            Behavior on border.color { ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing; } }
        }
    }
    MaterialIcon {
        icon: control.icon
        anchors.left: parent.left
        anchors.leftMargin: icon !== "" ? iconMargin : 0
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: control.iconSize
        color: control.iconColor
        visible: control.icon !== ""
        Behavior on color { ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing; } }
    }
}
