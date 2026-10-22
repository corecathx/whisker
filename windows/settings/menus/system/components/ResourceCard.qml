import QtQuick
import QtQuick.Layouts

import qs.modules
import qs.components

StyledRectangle {
    id: card

    required property string label
    required property string icon
    required property string value
    required property string detail
    required property real progress

    Layout.fillWidth: true
    Layout.preferredHeight: 148
    radius: Appearance.rounding.small
    color: Appearance.colors.m3surface_container_high

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MaterialIcon {
                icon: card.icon
                font.pixelSize: 20
                color: Appearance.colors.m3primary
            }

            StyledText {
                Layout.fillWidth: true
                text: card.label
                font.pixelSize: 14
                color: Appearance.colors.m3on_surface_variant
                elide: Text.ElideRight
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: card.value
            font.family: "Outfit SemiBold"
            font.pixelSize: 24
            color: Appearance.colors.m3on_surface
            elide: Text.ElideRight
        }

        StyledText {
            Layout.fillWidth: true
            text: card.detail
            font.pixelSize: 12
            color: Appearance.colors.m3on_surface_variant
            elide: Text.ElideRight
        }

        StyledProgressBar {
            Layout.fillWidth: true
            height: 8
            fill: Math.max(0, Math.min(card.progress / 100, 1))
        }
    }
}
