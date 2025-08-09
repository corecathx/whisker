import QtQuick
import QtQuick.Layouts
import qs.components
import qs.modules
import qs.services

Item {
    id: root
    property string icon: Bluetooth.icon
    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight

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
    }

}
