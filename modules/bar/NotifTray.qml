import QtQuick
import QtQuick.Layouts
import qs.components
import qs.modules
import qs.services

Item {
    id: root
    property string icon: "notifications"
    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    Behavior on implicitWidth { NumberAnimation { duration: Appearance.anim_medium; easing.type: Easing.OutExpo } }
    visible: icon !== ""
    Layout.preferredWidth: visible ? implicitWidth : 0
    Layout.preferredHeight: visible ? implicitHeight : 0

    RowLayout {
        id: container
        MaterialIcon {
            id: iconLabel
            font.pixelSize: 20
            icon: root.icon
            color: Appearance.colors.m3on_background
        }
        Rectangle {
            visible: NotifServer.data.length > 0
            implicitHeight: 14
            radius: 10
            width: this.implicitHeight
            color: Appearance.colors.m3primary
            Text {
                text: NotifServer.data.length
                anchors.centerIn: parent
                font.pixelSize: parent.height-2
                color: Appearance.colors.m3on_primary
            }
        }
    }

}
