import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import qs.modules
import qs.services

Item {
    id: root
    property string time
    property string date
    property bool showLabel: true  // control visibility

    Layout.preferredWidth: showLabel ? container.implicitWidth : 0
    Layout.preferredHeight: container.implicitHeight
    width: container.implicitWidth
    height: container.implicitHeight
    opacity: showLabel ? 1 : 0

    Column {
        spacing: -5
        id: container
        Text {
            id: label
            text: Qt.formatDateTime(Time.date, "HH:mm")
            color: Appearance.colors.m3on_surface
            font.pixelSize: 18
            font.bold: true
            lineHeight: 0.1
        }
        Text {
            id: date
            text: Qt.formatDateTime(Time.date, "ddd, dd/MM")
            color: Appearance.colors.m3on_surface
            font.pixelSize: 14
            lineHeight: 0.1
        }
    }

    Behavior on Layout.preferredWidth {
        NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic }
    }

    Behavior on opacity {
        NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic }
    }
}
