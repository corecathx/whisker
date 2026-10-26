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

    width: ListView.view.width
    height: 60

    signal clicked();

    StyledRectangle {
        id: bg
        anchors.fill: parent
        color: mouseArea.containsMouse || root.selected ? Appearance.colors.m3surface_container : Appearance.colors.m3surface
        radius: Appearance.rounding.large
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Log.info('windows/dock/components/LauncherItem.qml', 'clicked on ' + root.modelData + ' launcher item');
            modelData.execute()
            root.clicked();
        }
    }
    
    RowLayout {
        spacing: 10
        anchors {
            fill: parent
            margins: 20
            topMargin: 8
            bottomMargin: 8
        }

        IconImage {
            id: appIcon
            asynchronous: true
            source: Quickshell.iconPath(modelData.icon, true)
            width: 30
            height: 30
            visible: source != ""
            Layout.alignment: Qt.AlignVCenter
        }

        MaterialIcon {
            visible: appIcon.source == ""
            icon: {
                return "terminal";
            }
            font.pixelSize: 30
            color: Appearance.colors.m3on_surface
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            StyledText {
                Layout.fillWidth: true
                text: modelData.name
                font.pixelSize: 16
                font.bold: true
                color: Appearance.colors.m3on_surface
                elide: Text.ElideRight
            }
            StyledText {
                Layout.fillWidth: true
                text: modelData.comment
                font.pixelSize: 12
                color: Appearance.colors.m3on_surface_variant
                elide: Text.ElideRight
                visible: text != ''
            }
        }

        RowLayout {
            Layout.fillHeight: true
            StyledRectangle {
                width: 40
                height: 40
                radius: height

                color: starMouseArea.containsMouse ? Appearance.colors.m3surface_container : bg.color

                MaterialIcon {
                    anchors.centerIn: parent
                    icon: 'star'
                    filled: Preferences.widgets.dock.items.includes(modelData.id)
                    color: filled ? Appearance.colors.m3primary : Appearance.colors.m3on_surface_variant
                }
                MouseArea {
                    id: starMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        let items = [...Preferences.widgets.dock.items]
                        let index = items.indexOf(modelData.id)

                        if (index === -1)
                            items.push(modelData.id)
                        else
                            items.splice(index, 1)

                        Preferences.widgets.dock.items = items
                        Whisker.setPrefs("widgets.dock.items", JSON.stringify(items))
                    }
                }
            }
        }
    }
}