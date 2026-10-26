import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.whisker.modules
import qs.whisker.components

Item {
    id: section
    required property var modelData
    required property var emojis

    width: ListView.view.width
    height: visible ? sectionContent.implicitHeight + 10 : 0
    visible: searchField.text.trim() === '' || (section.emojis?.length ?? 0) !== 0

    ColumnLayout {
        id: sectionContent
        width: parent.width
        spacing: 10

        StyledText {
            text: section.modelData.name
            font.pixelSize: 16
            font.bold: true
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            visible: section.modelData.name === 'Recent'
                && (section.emojis?.length ?? 0) === 0
                && searchField.text.trim() === ''
            text: 'No recent emojies :('
            color: Appearance.colors.m3on_surface_variant
        }

        GridView {
            id: emojiGrid
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            visible: (section.emojis?.length ?? 0) > 0
            cellWidth: width / Math.max(1, Math.floor(width / 50))
            cellHeight: cellWidth
            interactive: false
            clip: false
            model: section.emojis

            delegate: StyledRectangle {
                required property var modelData

                width: emojiGrid.cellWidth - 8
                height: emojiGrid.cellHeight - 8
                radius: Appearance.rounding.medium
                color: emojiMouse.containsMouse
                    || (root.selectedEmoji
                        && root.selectedEmoji.category === section.modelData.name
                        && root.selectedEmoji.emoji === modelData.emoji)
                    ? Appearance.colors.m3surface_container_high
                    : Appearance.colors.m3surface_container

                StyledText {
                    anchors.centerIn: parent
                    text: modelData.emoji
                    font.pixelSize: 24
                }

                MouseArea {
                    id: emojiMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: root.copyEmoji(modelData)
                }
            }
        }
    }
}