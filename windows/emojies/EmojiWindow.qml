import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io
import qs.modules
import qs.components

Scope {
    id: root
    property var emojiModel: []
    property int margin: 20
    property int emojiSize: 50
    property int spacing: 10
    property string searchQuery: ""
    property int visibleCount: 100
    property real mouseX: 0
    property real mouseY: 0

    MouseArea {
        id: mouseTracker
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onPositionChanged: {
            root.mouseX = mouse.x
            root.mouseY = mouse.y
        }
    }

    Window {
        id: emojiPanel
        width: 450 + root.margin * 2
        height: 300 + root.margin * 2
        flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        visible: true
        color: "transparent"

        x: root.mouseX + 20
        y: root.mouseY + 20

        property int columns: Math.max(1, Math.floor((width - root.margin * 2 + spacing) / (emojiSize + spacing)))
        property real cellWidth: (width - root.margin * 2 - (columns - 1) * spacing) / columns

        Rectangle {
            anchors.fill: parent
            color: Appearance.colors.m3surface
            radius: 20
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.margin
            spacing: root.spacing

            StyledTextField {
                Layout.fillWidth: true
                height: 20
                leftPadding: undefined
                padding: 10
                placeholderText: "Search emoji..."
                onTextChanged: {
                    root.searchQuery = text.toLowerCase()
                    root.visibleCount = 100
                }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                interactive: true
                contentWidth: width
                contentHeight: grid.implicitHeight
                onContentYChanged: {
                    if (contentY + height >= contentHeight - 200) {
                        root.visibleCount += 200
                    }
                }
                focus: true

                Grid {
                    id: grid
                    width: parent.width
                    columns: emojiPanel.columns
                    rowSpacing: root.spacing
                    columnSpacing: root.spacing
                    anchors.margins: root.margin

                    Repeater {
                        model: emojiModel
                            .filter(function(e) {
                                return root.searchQuery === "" || e[1].toLowerCase().includes(root.searchQuery)
                            })
                            .slice(0, root.visibleCount)

                        delegate: Rectangle {
                            width: emojiPanel.cellWidth
                            height: emojiPanel.cellWidth
                            radius: 20
                            color: Appearance.colors.m3surface_container

                            StyledText {
                                anchors.centerIn: parent
                                text: modelData[0]
                                font.pixelSize: emojiPanel.cellWidth * 0.6
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = Appearance.colors.m3surface_container_high
                                onExited: parent.color = Appearance.colors.m3surface_container
                                onClicked: Log.info("windows/emojies/EmojiWindow.qml", "Emoji clicked:" + modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    function load(content) {
        try {
            emojiModel = JSON.parse(content)
        } catch (e) {
            Log.error("windows/emojies/EmojiWindow.qml", "Failed to load emoji JSON:" + e)
        }
    }

    FileView {
        path: Utils.getPath("data/emoji_en-US.json")
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.load(text())
    }
}
