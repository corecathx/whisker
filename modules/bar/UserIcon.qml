import QtQuick
import Quickshell.Widgets
import Quickshell
import qs.modules
Rectangle {
    id: root
    clip: true
    implicitWidth: hovered | Globals.visible_quickPanel ? userName.width + avatarClip.width + 30 : 30
    height: 30
    color: "transparent"
    radius: 30
    property bool hovered: false
    border {
        width: hovered | Globals.visible_quickPanel ? 2 : 0
        color: Colors.foreground

        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    ClippingRectangle {
        id: textClip
        anchors.fill: parent
        radius: 30
        color: "transparent"
        width: userName.width
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        Text {
            id: userName
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            
            visible: parent.width > 41
            anchors.leftMargin: 8
            text: Quickshell.env('USER')
            color: Colors.foreground
            font.bold: true
            
        }
        Item {
            implicitWidth: 20
        }
    }

    ClippingRectangle {
        id: avatarClip
        width: 30
        height: 30
        radius: 30
        color: "transparent"

        IconImage {
            anchors.fill: parent
            source: Appearance.profileImage
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.hovered = true
            onExited: root.hovered = false
            onClicked: Globals.toggle_quickPanel()
        }
    }

}
