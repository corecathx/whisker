import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules
import qs.components

Scope {
    id: root
    property int margin: 20
    property int emojiSize: 50
    property int spacing: 10

    PanelWindow {
        id: emojiPanel
        implicitWidth: 450 + root.margin * 2
        implicitHeight: 300 + root.margin * 2
        exclusionMode: ExclusionMode.Normal
        anchors {
            right: true
            bottom:true
        }
        visible: true
        color: "transparent"

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

            }

            Grid {
                Layout.fillWidth: true
                Layout.fillHeight: true
                anchors.margins: root.margin
                columns: emojiPanel.columns
                rowSpacing: root.spacing
                columnSpacing: root.spacing

                Repeater {
                    model: ["😀", "😂", "😍", "👍", "🎉", "😢", "🔥", "💯"]

                    delegate: Rectangle {
                        width: emojiPanel.cellWidth
                        height: emojiPanel.cellWidth
                        radius: 20
                        color: Appearance.colors.m3surface_container

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: emojiPanel.cellWidth * 0.6
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.color = Appearance.colors.m3surface_container_high
                            onExited: parent.color = Appearance.colors.m3surface_container
                            onClicked: console.log("Emoji clicked:", modelData)
                        }
                    }
                }
            }
        }

    }
}
