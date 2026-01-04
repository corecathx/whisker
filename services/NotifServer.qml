pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import qs.modules
Singleton {
    id: root

    property var _notifications: []
    property int _updateCounter: 0

    property ScriptModel data: ScriptModel {
        values: root._notifications
    }

    property ScriptModel popups: ScriptModel {
        values: {
            root._updateCounter;
            const filtered = root._notifications.filter(n => {
                return n.popup;
            });
            return filtered;
        }
    }

    NotificationServer {
        id: server
        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notif => {
            notif.tracked = true;
            const newNotif = notifComp.createObject(root, {
                popup: true,
                notification: notif
            });

            root._notifications = [...root._notifications, newNotif];
            root._updateCounter++;
        }
    }

    function removeNotification(notifObj) {
        root._notifications = root._notifications.filter(n => n !== notifObj);
        root._updateCounter++;
    }

    function clearAll() {
        root._notifications.forEach(n => {
            if (n.notification && !n.notification.Retainable.dropped) {
                n.notification.dismiss();
            }
        });
        root._notifications = [];
    }

    component Notif: QtObject {
        id: notif

        property bool popup
        readonly property date time: new Date()

        readonly property string timeStr: {
            const diff = Time.date.getTime() - time.getTime();
            const m = Math.floor(diff / 60000);
            const h = Math.floor(m / 60);

            if (h < 1 && m < 1)
                return "now";
            if (h < 1)
                return `${m}m`;
            return `${h}h`;
        }

        required property Notification notification

        readonly property string summary: notification.summary
        readonly property string body: notification.body
        readonly property string appIcon: notification.appIcon
        readonly property string appName: notification.appName
        readonly property string image: notification.image
        readonly property int urgency: notification.urgency
        readonly property list<NotificationAction> actions: notification.actions

        readonly property Timer timer: Timer {
            running: notif.popup
            interval: {
                if (notif.notification.urgency == NotificationUrgency.Critical || notif.actions.length > 1)
                {
                    return 99999;
                }
                const timeout = notif.notification.expireTimeout;
                return timeout > 0 ? timeout : 5000;
            }
            onTriggered: {
                notif.popup = false;
            }
        }

        readonly property Connections retainConn: Connections {
            target: notif.notification.Retainable

            function onDropped() {
                root.removeNotification(notif);
            }

            function onAboutToDestroy() {
                notif.destroy();
            }
        }

        readonly property Connections closeConn: Connections {
            target: notif.notification

            function onClosed(reason) {
                root.removeNotification(notif);
            }
        }

        function dismiss() {
            Log.info("services/NotifServer.qml", "Dismissing a notification...");
            notif.notification.dismiss();
        }
    }

    Component {
        id: notifComp
        Notif {}
    }
}
