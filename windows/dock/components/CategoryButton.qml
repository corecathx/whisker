import QtQuick
import QtQuick.Layouts

import qs.modules
import qs.components

Item {
    id: root

    property string text: ""
    property string icon: ""
    property bool selected: false
    property bool sidebarOpened: false

    signal clicked()

    StyledRectangle {
        anchors.fill: parent
        radius: Appearance.rounding.large
        color: root.selected
            ? Appearance.colors.m3primary_container
            : mouseArea.containsMouse
                ? Appearance.colors.m3surface_container_high
                : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Appearance.animation.fastest
                easing.type: Appearance.animation.easing
            }
        }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 10
        }
        spacing: 10

        MaterialIcon {
            icon: root.icon
            filled: root.selected
            font.pixelSize: 20
            color: root.selected
                ? Appearance.colors.m3on_primary_container
                : Appearance.colors.m3on_surface_variant
        }

        StyledText {
            Layout.fillWidth: true
            text: root.text
            font.pixelSize: 14
            color: root.selected
                ? Appearance.colors.m3on_primary_container
                : Appearance.colors.m3on_surface
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}