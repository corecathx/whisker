pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    readonly property real defaultTimeout: 5000

    property var notifications: []

    readonly property ScriptModel list: ScriptModel {
        values: root.notifications
    }

    readonly property ScriptModel popups: ScriptModel {
        values: root.notifications.filter(n => n.popup)
    }

    readonly property NotificationServer server: NotificationServer {
        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        inlineReplySupported: true

        onNotification: notification => {
            notification.tracked = true

            const item = notifItem.createObject(root, {
                modelData: notification
            })

            root.notifications = [...root.notifications, item]
        }
    }

    function clear(): void {
        while (server.trackedNotifications.values.length > 0)
            for (const notification of server.trackedNotifications.values)
                notification.dismiss()
    }

    function remove(notif): void {
        root.notifications = root.notifications.filter(n => n !== notif)
        notif.destroy()
    }

    component NotifItem: QtObject {
        id: notif

        required property Notification modelData
        readonly property Notification raw: modelData

        property bool popup: true

        readonly property date time: new Date()

        readonly property string timeStr: {
            const diff = Time.date.getTime() - time.getTime()
            const m = Math.floor(diff / 60000)
            const h = Math.floor(m / 60)

            if (h < 1 && m < 1)
                return "now"
            if (h < 1)
                return `${m}m`
            return `${h}h`
        }

        readonly property Timer timer: Timer {
            running: notif.popup

            interval: {
                if (notif.raw.urgency === NotificationUrgency.Critical
                    || notif.raw.actions.length > 1)
                    return 99999

                const timeout = notif.raw.expireTimeout
                return timeout > 0 ? timeout : root.defaultTimeout
            }

            onTriggered: {
                notif.popup = false
            }
        }

        readonly property Connections closeConn: Connections {
            target: notif.raw

            function onClosed(reason) {
                root.remove(notif)
            }
        }

        function dismiss(): void {
            notif.raw.dismiss()
        }
    }

    Component {
        id: notifItem
        NotifItem {}
    }
}