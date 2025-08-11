import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.modules

Rectangle {
    id: root
    property bool startAnim: false

    property string title: "WawaApp"
    property string body: "No content"
    property bool tracked: false
    property string image: ""
    property var buttons: [
        { label: "Okay!", onClick: () => console.log("Okay") }
    ]

    opacity: tracked ? 1 : (startAnim ? 1 : 0)
    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.anim_medium
            easing.type: Easing.OutCubic
        }
    }

    Layout.fillWidth: true
    radius: 20
    color: Appearance.colors.m3surface
    implicitHeight: Math.max(content.implicitHeight + 40, 80)

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        ClippingRectangle {
            visible: root.image
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
            Text {
                text: root.title
                font.bold: true
                font.pixelSize: 20
                wrapMode: Text.Wrap
                color: Appearance.colors.m3on_surface
                Layout.fillWidth: true
            }

            Text {
                text: root.body.length > 123 ? root.body.substr(0, 120) + "..." : root.body
                visible: root.body.length > 0
                font.pixelSize: 14
                color: Appearance.colors.m3on_surface_variant
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            RowLayout {
                visible: root.buttons.length > 1
                Layout.topMargin: 5
                Layout.preferredHeight: 40
                Layout.fillWidth: true
                spacing: 20

                Repeater {
                    model: buttons

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 20
                        color: index === 0
                            ? Appearance.colors.m3primary
                            : Appearance.colors.m3secondary_container

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: index === 0
                                ? Appearance.colors.m3on_primary
                                : Appearance.colors.m3on_secondary_container
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.onClick()
                        }
                    }
                }
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        visible: root.buttons.length === 1
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            // invoke the only button's onClick
            root.buttons[0].onClick()
        }
    }
    Component.onCompleted: {
        startAnim = true
    }
}
