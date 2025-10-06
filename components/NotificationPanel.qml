import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules
import qs.preferences

Item {
    id: root
    implicitWidth: 400
    implicitHeight: container.implicitHeight + 10
    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        anchors.topMargin: 5
        id: container
        spacing: 10
        RowLayout {
            StyledButton {
                icon: checked ? "notifications" : "notifications_off"
                checked: Preferences.notificationEnabled
                checkable: true
                onToggled: {
                    Quickshell.execDetached({ command: [ 'whisker', 'prefs', 'set', 'notificationEnabled', checked ] })
                }
                implicitHeight: 30
                HoverHandler {
                    id: hoverDnd
                }
                StyledPopout {
                    hoverTarget: hoverDnd
                    Text {
                        text: "If disabled, you won't get notification popups.\nYou can still see past notifications here."
                        font.pixelSize: 14
                        color: Appearance.colors.m3on_surface
                    }
                }
            }
            Text {
                text: "Notifications"
                font.pixelSize: 16
                font.family: "Outfit Medium"
                color: Appearance.colors.m3on_surface
                Layout.alignment: Qt.AlignHCenter
            }
            Item { Layout.fillWidth: true }
            StyledButton {
                icon: "clear_all"
                onClicked: NotifServer.data = []
                implicitHeight: 30
                secondary: true
                text: "Clear All"
            }
        }
        BaseCard {
            cardMargin: 10
            cardSpacing: 10
            verticalPadding: 20
            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                Text {
                    visible: NotifServer.data.length === 0
                    text: "You're all caught up!"
                    font.pixelSize: 14
                    color: Appearance.colors.m3secondary
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Repeater {
                    id: rep
                    model: NotifServer.data

                    delegate: NotificationChild {
                        id: child
                        Layout.fillWidth: true

                        title: modelData.summary
                        body: modelData.body
                        image: modelData.image || modelData.appIcon
                        rawNotif: modelData
                        tracked: true
                        buttons: modelData.actions.map(action => ({
                                    label: action.text,
                                    onClick: () => {
                                        action.invoke();
                                    }
                                }))
                    }
                }
            }
        }
    }
}
