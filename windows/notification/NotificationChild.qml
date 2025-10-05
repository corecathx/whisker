import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.modules
import qs.components

Rectangle {
    id: root
    property bool startAnim: false

    property string title: "WawaApp"
    property string body: "No content"
    property var rawNotif: null
    property bool tracked: false
    property string image: ""
    property var buttons: [
        { label: "Okay!", onClick: () => console.log("Okay") }
    ]

    opacity: tracked ? 1 : (startAnim ? 1 : 0)
    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.anim_fast
            easing.type: Easing.OutExpo
        }
    }

    Layout.fillWidth: true
    radius: 20

    property bool hovered: mouseHandler.containsMouse
    property bool clicked: mouseHandler.containsPress
    color: hovered ? (clicked ? Appearance.colors.m3surface_container_high : Appearance.colors.m3surface_container_low) : Appearance.colors.m3surface
    Behavior on color {
        ColorAnimation {
            duration: Appearance.anim_fast
            easing.type: Easing.OutExpo
        }
    }
    implicitHeight: Math.max(content.implicitHeight + 30, 80)

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        ClippingRectangle {
            width: 50
            height: 50
            radius: 20
            clip: true
            color: root.image === "" ? Appearance.colors.m3surface_container : "transparent"
            Image {
                anchors.fill: parent
                source: root.image
                fillMode: Image.PreserveAspectCrop
                smooth: true
            }
            MaterialIcon {
                icon: "terminal"
                color: Appearance.colors.m3on_surface_variant
                anchors.centerIn: parent
                visible: root.image === ""
                font.pixelSize: 32
            }
        }

        ColumnLayout {
            Text {
                text: root.title
                font.bold: true
                font.pixelSize: 18
                wrapMode: Text.Wrap
                color: Appearance.colors.m3on_surface
                Layout.fillWidth: true
            }

            Text {
                text: root.body.length > 123 ? root.body.substr(0, 120) + "..." : root.body
                visible: root.body.length > 0
                font.pixelSize: 12
                color: Appearance.colors.m3on_surface_variant
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            RowLayout {
                visible: root.buttons.length > 1
                Layout.preferredHeight: 40
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: buttons

                    StyledButton {
                        Layout.fillWidth: true
                        implicitHeight: 30
                        implicitWidth: 0
                        text: modelData.label
                        base_bg: index !== 0
                            ? Appearance.colors.m3secondary_container
                            : Appearance.colors.m3primary

                        base_fg: index !== 0
                            ? Appearance.colors.m3on_secondary_container
                            : Appearance.colors.m3on_primary
                        onClicked: modelData.onClick()
                    }
                }
            }
        }
    }
    MouseArea {
        id: mouseHandler
        anchors.fill: parent
        hoverEnabled: true
        visible: root.buttons.length === 0 || root.buttons.length === 1 
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.buttons.length === 1 && root.buttons[0].onClick) {
                root.buttons[0].onClick()
                root.rawNotif?.notification.dismiss()
            } else if (root.buttons.length === 0) {
                console.log("[Notification] Dismissed a notification with no action.")
                root.rawNotif.notification.tracked = false
                root.rawNotif.popup = false
                root.rawNotif?.notification.dismiss()
            } else {
                console.log("[Notification] Dismissed a notification with multiple actions.")
                root.rawNotif?.notification.dismiss()
            }
        }
    }
    Component.onCompleted: {
        startAnim = true
    }
}
