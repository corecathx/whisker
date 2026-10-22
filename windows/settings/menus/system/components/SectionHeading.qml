import QtQuick
import QtQuick.Layouts

import qs.modules
import qs.components

RowLayout {
    required property string title
    required property string icon

    Layout.fillWidth: true
    spacing: 10

    // StyledRectangle {
    //     Layout.preferredWidth: 36
    //     Layout.preferredHeight: 36
    //     radius: Appearance.rounding.medium
    //     color: Appearance.colors.m3secondary_container

    //     MaterialIcon {
    //         anchors.centerIn: parent
    //         icon: parent.parent.icon
    //         font.pixelSize: 20
    //         color: Appearance.colors.m3on_secondary_container
    //     }
    // }

    StyledText {
        text: parent.title
        font.family: "Outfit SemiBold"
        font.pixelSize: 18
        color: Appearance.colors.m3on_surface
    }
}