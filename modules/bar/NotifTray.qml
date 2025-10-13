import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.components
import qs.modules
import qs.services
import qs.preferences

Item {
    id: root
    property string icon: Preferences.notificationEnabled ? "notifications" : "notifications_off"
    property bool inLockScreen: false
    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    Behavior on implicitWidth { NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing } }
    visible: icon !== ""
    Layout.preferredWidth: visible ? implicitWidth : 0
    Layout.preferredHeight: visible ? implicitHeight : 0

    RowLayout {
        id: container
        MaterialIcon {
            id: iconLabel
            font.pixelSize: 20
            icon: root.icon
            color: Appearance.colors.m3on_background
        }
        Rectangle {
            visible: Preferences.notificationEnabled && NotifServer.data.length > 0
            implicitHeight: 14
            radius: 10
            width: this.implicitHeight
            color: Appearance.colors.m3primary
            StyledText {
                text: NotifServer.data.length
                anchors.centerIn: parent
                font.pixelSize: parent.height-2
                color: Appearance.colors.m3on_primary
            }
        }
    }

    HoverHandler {
        id: detect
    }

    StyledPopout {
        hoverTarget: !root.inLockScreen ? detect : null
        interactable: true
                hCenterOnItem: true

        Component {
            NotificationPanel {
            }
        }
    }
}
