import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.components
import qs.modules

Slider {
    property string icon: 'adjust'
    Layout.fillWidth: true

    id: control
    from: 0
    to: 100
    value: 50
    stepSize: 0.1

    implicitHeight: 40

    background: Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - parent.height
        height: 10
        radius: 20
        color: Appearance.colors.m3surface_container
    }

    Rectangle {
        id: bar
        width: parent.height + control.visualPosition * (parent.width-parent.height)
        Behavior on width {
            NumberAnimation {
                duration: Appearance.anim_fast * 0.5
                easing.type: Easing.OutCubic
            }
        }
        height: parent.height
        radius: 20
        color: Appearance.colors.m3primary
    }
    handle: MaterialIcon {
        icon: parent.icon
        color: Appearance.colors.m3on_primary
        font.pixelSize: 24
        // ass logic :wilted_rose:
        anchors.right: bar.width > bar.height ? bar.right : undefined
        anchors.left: bar.width > bar.height ? undefined : bar.left
        anchors.centerIn: bar.width > bar.height ? undefined : bar
        anchors.verticalCenter: bar.verticalCenter
        anchors.rightMargin: bar.width > bar.height ? 10 : 0
        Behavior on x {
            NumberAnimation {
                duration: Appearance.anim_fast * 0.5
                easing.type: Easing.OutCubic
            }
        }
    }
}
