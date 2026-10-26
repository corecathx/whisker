import QtQuick
import QtQuick.Layouts

import qs.whisker.modules
import qs.whisker.components

StyledRectangle {
    id: item

    required property string label
    required property string value
    required property string icon

    color: Appearance.colors.m3surface_container_high
    radius: Appearance.rounding.small

    height: 60
    
    RowLayout {
        id: itemLayout
        anchors {
            fill: parent
            margins: 10
            leftMargin: 20
        }
        spacing: 12

        MaterialIcon {
            icon: item.icon
            color: Appearance.colors.m3on_surface_variant
            size: 22
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            StyledText {
                text: item.label
                color: Appearance.colors.m3on_surface_variant
                font.pixelSize: 12
            }

            StyledText {
                Layout.fillWidth: true
                text: item.value
                color: Appearance.colors.m3on_surface
                font.pixelSize: 14
                elide: Text.ElideRight
            }
        }
    }
}
