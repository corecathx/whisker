import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs.whisker.modules
import qs.whisker.components
import qs.whisker.preferences
import qs.whisker.services

Item {
    id: root

    required property var modelData
    property bool selected: false

    property bool hovered: mouseArea.containsMouse

    signal clicked()

    StyledRectangle {
        anchors.fill: parent
        color: root.hovered || root.selected ? Appearance.colors.m3surface_container : "transparent"
        radius: Appearance.rounding.large
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            IconImage {
                id: appIcon
                anchors.centerIn: parent
                asynchronous: true
                source: Quickshell.iconPath(root.modelData.icon, true)
                width: 40
                height: 40
                visible: source != ""
            }

            MaterialIcon {
                anchors.centerIn: parent
                visible: appIcon.source == ""
                icon: "terminal"
                font.pixelSize: 36
                color: Appearance.colors.m3on_surface
            }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            text: root.modelData.name
            font.pixelSize: 12
            color: Appearance.colors.m3on_surface
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            maximumLineCount: 2
        }
    }

    StyledRectangle {
        id: starBackground
        anchors {
            top: parent.top
            right: parent.right
            margins: 4
        }
        width: 28
        height: 28
        radius: height
        color: starMouseArea.containsMouse ? Appearance.colors.m3surface_container_high : "transparent"
        z: 2

        MaterialIcon {
            anchors.centerIn: parent
            icon: "star"
            filled: Preferences.widgets.dock.items.includes(root.modelData.id)
            color: filled ? Appearance.colors.m3primary : Appearance.colors.m3on_surface_variant
            font.pixelSize: 18
        }

        MouseArea {
            id: starMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                let items = [...Preferences.widgets.dock.items]
                let index = items.indexOf(root.modelData.id)

                if (index === -1)
                    items.push(root.modelData.id)
                else
                    items.splice(index, 1)

                Preferences.widgets.dock.items = items
                Whisker.setPrefs("widgets.dock.items", JSON.stringify(items))
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            Log.info("windows/dock/components/LauncherGridItem.qml", "clicked on " + root.modelData.name + " launcher item")
            root.modelData.execute()
            root.clicked()
        }
    }
}