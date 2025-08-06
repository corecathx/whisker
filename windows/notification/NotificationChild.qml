import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.modules

Rectangle {
    id: root
    signal dismiss()

    property string title: "WawaApp"
    property string body: "No content"
    property string image: ""
    property var buttons: [
        { label: "Okay!", onClick: () => console.log("Okay") }
    ]

    Layout.fillWidth: true
    radius: 20
    color: Appearance.panel_color
    border.color: Colors.accent
    border.width: 1
    implicitHeight: Math.max(content.implicitHeight + 40, 80)

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        ClippingRectangle {
            visible: !!root.image
            width: 60
            height: 60
            radius: 20
            clip: true
            color: "transparent"
            Image {
                anchors.fill: parent
                source: root.image
                fillMode: Image.PreserveAspectCrop
                smooth: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            Text {
                text: root.title
                font.bold: true
                font.pixelSize: 20
                color: Colors.lighten(Colors.foreground, 0.25)
            }

            Text {
                text: root.body
                font.pixelSize: 14
                color: Colors.foreground
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            RowLayout {
                visible: root.buttons.length > 0
                Layout.topMargin: 5
                Layout.preferredHeight: 25
                Layout.fillWidth: true
                spacing: 20

                Repeater {
                    model: (buttons.length > 0
                        ? buttons
                        : [ { label: "Dismiss", onClick: () => console.log("Dismissed") } ])
                            .map(b => ({
                                label: (b.label && b.label.trim()) || "Dismiss",
                                onClick: b.onClick || (() => console.log("Dismiss clicked"))
                            }))


                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 20
                        color: index === 0
                            ? Colors.accent
                            : Colors.darken(Colors.accent, 0.1)

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: Colors.lighten(Colors.foreground, 0.25)
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: b.onClick || (() => root.dismiss())
                        }
                    }
                }
            }
        }
    }
}
