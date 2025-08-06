import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import Quickshell.Wayland
import qs.modules
import qs.services

Scope {
    id: root
    property int innerSpacing: 10

    PanelWindow {
        id: window
        implicitWidth: 540
        visible: true
        anchors.top: true
        anchors.bottom: true
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Normal

        mask: Region {
            width: window.width
            height: notificationList.implicitHeight
        }

        ColumnLayout {
            id: notificationList
            spacing: root.innerSpacing
            anchors.margins: 10
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            Repeater {
                model: NotifServer.popups
                delegate: NotificationChild {
                    id: child
                    title: modelData.summary
                    body: modelData.body
                    image: modelData.image || modelData.appIcon

                    buttons: modelData.actions.map(action => ({
                        label: action.label,
                        onClick: () => {
                            action.activate()
                            modelData.popup = false
                        }
                    }))
                    onDismiss: {
                        modelData.popup = false
                        NotifServer.removeById(modelData.notification.id)
                    }
                }
            }
        }

    }
}
