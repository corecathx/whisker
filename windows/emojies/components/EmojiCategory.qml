import QtQuick

import qs.modules
import qs.components

StyledRectangle {
    required property var modelData

    width: 40
    height: 40
    radius: Appearance.rounding.medium
    color: tabMouse.containsMouse
        ? Appearance.colors.m3surface_container_high
        : 'transparent'

    MaterialIcon {
        anchors.centerIn: parent
        icon: modelData.icon
        size: 22
    }

    MouseArea {
        id: tabMouse
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            const index = root.categories.findIndex(
                category => category.name === modelData.name
            )

            if (index >= 0)
                emojiList.positionViewAtIndex(index, ListView.Beginning)

            searchField.forceActiveFocus()
        }
    }
}
