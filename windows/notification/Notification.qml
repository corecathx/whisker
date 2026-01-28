import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.modules
import qs.components
import qs.preferences
import qs.services

Scope {
    id: root

    PanelWindow {
        id: window
        implicitWidth: 440
        visible: true
        anchors {
            top: true
            bottom: true
            left: Preferences.bar.position === 'right'
            right: Preferences.bar.position !== 'right'
        }
        margins.right: -10
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Normal

        mask: Region {
            width: window.width
            height: (listView.contentHeight > 0 ? Math.min(listView.contentHeight + 20, 500) : 0)
        }

        Item {
            id: notificationList
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: 10
                topMargin: 10
                rightMargin: 10
            }
            height: Math.min(bgRectangle.height, 500)

            Rectangle {
                id: bgRectangle
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    leftMargin: 10
                    rightMargin: 10
                }
                height: Math.min(listView.contentHeight > 0 ? listView.contentHeight + 20 : 0, 500)
                color: Appearance.panel_color
                radius: Appearance.rounding.large

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowOpacity: 1
                    shadowColor: Appearance.colors.m3shadow
                    shadowBlur: 1
                    shadowScale: 1
                }

                Behavior on height {
                    NumberAnimation {
                        duration: Appearance.animation.fast
                        easing.type: Appearance.animation.easing
                    }
                }
            }

            ListView {
                id: listView
                anchors {
                    fill: parent
                    topMargin: 10
                    bottomMargin: 10
                    leftMargin: 20
                    rightMargin: 20
                }

                spacing: 10
                clip: true
                interactive: contentHeight > 480

                model: Preferences.misc.notificationEnabled ? NotifServer.popups : null

                property bool stickToBottom: true
                property bool hasNewItems: false

                onMovementStarted: stickToBottom = false
                onMovementEnded: {
                    stickToBottom = atYEnd
                    if (stickToBottom)
                        hasNewItems = false
                }

                Behavior on contentY {
                    NumberAnimation {
                        duration: Appearance.animation.fast
                        easing.type: Appearance.animation.easing
                    }
                }

                onContentHeightChanged: {
                    if (stickToBottom) {
                        contentY = Math.max(0, contentHeight - height)
                    } else {
                        hasNewItems = true
                    }
                }

                add: Transition {
                    NumberAnimation {
                        properties: "opacity"
                        from: 0
                        to: 1
                        duration: Appearance.animation.fast
                        easing.type: Appearance.animation.easing
                    }
                }

                remove: Transition {
                    NumberAnimation {
                        properties: "opacity"
                        to: 0
                        duration: Appearance.animation.fast
                        easing.type: Appearance.animation.easing
                    }
                }

                displaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: Appearance.animation.fast
                        easing.type: Appearance.animation.easing
                    }
                }

                delegate: NotificationChild {
                    animateEntry: true
                    width: listView.width
                    title: modelData.summary
                    body: modelData.body
                    image: modelData.image || modelData.appIcon
                    notifData: modelData
                    radius: Appearance.rounding.medium
                    buttons: modelData.actions.map(action => ({
                        label: action.text,
                        onClick: () => action.invoke()
                    }))
                }
            }
            Rectangle {
                id: newNotifIndicator
                visible: listView.hasNewItems
                opacity: visible ? 1 : 0

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: 12
                }

                radius: Appearance.rounding.extraLarge
                color: Appearance.colors.m3primary
                height: 32
                width: indicatorText.implicitWidth + 24

                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.animation.fast
                        easing.type: Appearance.animation.easing
                    }
                }

                StyledText {
                    id: indicatorText
                    anchors.centerIn: parent
                    text: "New notifications"
                    color: Appearance.colors.m3on_primary
                    font.pixelSize: 13
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listView.stickToBottom = true
                        listView.hasNewItems = false
                        listView.contentY = Math.max(0, listView.contentHeight - listView.height)
                    }
                }
            }

        }
    }
}
