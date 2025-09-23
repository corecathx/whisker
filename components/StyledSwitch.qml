import QtQuick
import QtQuick.Controls
import qs.modules
import qs.components

Item {
    id: root
    width: 60
    height: 34

    property bool checked: false
    signal toggled(bool checked)

    property color trackOn: Appearance.colors.m3primary
    property color trackOff: Appearance.colors.m3surface_variant
    property color thumbColorOn: Appearance.colors.m3on_primary
    property color thumbColorOff: Appearance.colors.m3on_surface_variant
    property color iconColor: Appearance.colors.m3primary

    property int trackRadius: height / 2
    property int thumbSize: height - (checked ? 12 : 18)
    Behavior on thumbSize { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic } }

    Rectangle {
        id: track
        anchors.fill: parent
        radius: trackRadius
        color: root.checked ? trackOn : trackOff
        border.width: root.checked ? 0 : 2
        border.color: Appearance.colors.m3outline
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    Rectangle {
        id: thumb
        width: thumbSize
        height: thumbSize
        radius: thumbSize / 2
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? parent.width - width - 6 : 9
        color: root.checked ? thumbColorOn : thumbColorOff

        Behavior on x     { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation  { duration: Appearance.anim_fast; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
