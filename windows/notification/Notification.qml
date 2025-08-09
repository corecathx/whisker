import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import Quickshell.Wayland
import qs.modules
import qs.services

// to whoever reading this i'm so sorry that you have to witness this abomination :pensive: :pray:
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
            height: {
                var total = 0
                for (let i = 0; i < rep.count; i++) {
                    var child = rep.itemAt(i)
                    if (child) {
                        total += child.height + (i < rep.count - 1 ? root.innerSpacing : 0)
                    }
                }
                return total
            }
        }

        Item {
            id: notificationList
            anchors.margins: 10
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            Repeater {
                id: rep
                model: NotifServer.popups

                delegate: NotificationChild {
                    id: child
                    width: window.width - 20
                    x: 10

                    y: {
                        var pos = 0
                        for (let i = 0; i < index; i++) {
                            var prev = rep.itemAt(i)
                            if (prev)
                                pos += prev.height + root.innerSpacing
                        }
                        return pos - (tracked ? 0 : 20)
                    }

                    Component.onCompleted: {
                        y += tracked ? 0 : 20
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: Appearance.anim_medium
                            easing.type: Easing.OutCubic
                        }
                    }

                    title: modelData.summary
                    body: modelData.body
                    image: modelData.image || modelData.appIcon
                    tracked: {
                        // this is terrible, but eh, whatever
                        if (!modelData.shown) {
                            modelData.shown = true;
                            return false
                        }
                        return true

                    }
                    buttons: modelData.actions.map(action => ({
                        label: action.text,
                        onClick: () => {
                            action.invoke()
                        }
                    }))
                }
            }

        }

    }
}
