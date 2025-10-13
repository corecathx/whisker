import QtQuick
import QtQuick.Layouts
import qs.components
import qs.modules

BaseRowCard {
    id: infoCard

    property string icon: "info"
    property color backgroundColor: Appearance.colors.m3primary
    property color contentColor: Appearance.colors.m3on_primary
    property string title: "Title"
    property string description: "Description"

    cardSpacing: 0
    color: backgroundColor

    MaterialIcon {
        id: infoIcon
        icon: infoCard.icon
        font.pixelSize: 26
        color: contentColor
    }

    ColumnLayout {
        anchors.left: infoIcon.right
        anchors.leftMargin: 20

        StyledText {
            text: infoCard.title
            font.bold: true
            color: contentColor
            font.pixelSize: 14
        }

        StyledText {
            text: infoCard.description
            color: contentColor
            font.pixelSize: 12
        }
    }
}
