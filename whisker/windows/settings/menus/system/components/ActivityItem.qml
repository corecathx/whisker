import QtQuick
import QtQuick.Layouts

import qs.whisker.modules
import qs.whisker.components

ColumnLayout {
    id: activityItem
    required property string label
    required property string value
    required property string icon

    spacing: 8

    RowLayout {
        spacing: 6

        MaterialIcon {
            icon: activityItem.icon
            font.pixelSize: 16
            color: Appearance.colors.m3primary
        }

        StyledText {
            text: activityItem.label
            font.pixelSize: 12
            color: Appearance.colors.m3on_surface_variant
        }
    }

    StyledText {
        Layout.fillWidth: true
        text: activityItem.value
        font.family: "Outfit SemiBold"
        font.pixelSize: 15
        color: Appearance.colors.m3on_surface
        elide: Text.ElideRight
    }
}