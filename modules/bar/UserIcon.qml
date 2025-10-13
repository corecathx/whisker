import QtQuick
import Quickshell.Widgets
import Quickshell
import qs.modules
import qs.components

Rectangle {
    id: root
    clip: true
    property bool hovered: false
    property bool verticalMode: false

    implicitWidth: verticalMode ? 30 : (hovered || Globals.visible_quickPanel ? userName.width + avatarClip.width + 30 : 30)
    implicitHeight: verticalMode ? (hovered || Globals.visible_quickPanel ? userName.width + avatarClip.height + 30 : 30) : 30

    color: Colors.opacify(Appearance.colors.m3surface, 0.7)
    radius: 20

    border {
        width: hovered || Globals.visible_quickPanel ? 2 : 0
        color: Appearance.colors.m3on_surface
        Behavior on width { NumberAnimation { duration: 250; easing.type: Appearance.animation.easing } }
    }

    Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Appearance.animation.easing } }
    Behavior on implicitHeight { NumberAnimation { duration: 250; easing.type: Appearance.animation.easing } }

    ClippingRectangle {
        id: textClip
        anchors.fill: parent
        radius: 30
        color: "transparent"

        StyledText {
            id: userName
            text: Quickshell.env('USER')
            color: Appearance.colors.m3on_background
            font.bold: true
            visible: hovered || Globals.visible_quickPanel

            transform: Rotation {
                id: rot
                origin.x: userName.width / 2
                origin.y: userName.height / 2
                angle: verticalMode ? -90 : 0
            }

            x: verticalMode ? -12 : 40
            y: verticalMode ? parent.height - userName.width - 5 : parent.height / 2 - userName.height / 2
        }
    }

    ClippingRectangle {
        id: avatarClip
        width: 30
        height: 30
        radius: 30
        color: "transparent"

        IconImage { anchors.fill: parent; source: Appearance.profileImage }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.hovered = true
            onExited: root.hovered = false
            onClicked: Globals.toggle_quickPanel()
        }
    }
}
