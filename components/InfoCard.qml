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

    RowLayout {
        anchors.fill: parent
        spacing: 12

        MaterialIcon {
            id: infoIcon
            icon: infoCard.icon
            font.pixelSize: 22
            color: contentColor
            Layout.alignment: Qt.AlignTop
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            StyledText {
                text: infoCard.title
                font.family: "Outfit SemiBold"
                color: contentColor
                font.pixelSize: 13
            }

            StyledText {
                text: infoCard.description
                color: contentColor
                font.pixelSize: 12
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}
