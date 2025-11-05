import QtQuick
import QtQml.Models
import QtQuick.Layouts
import qs.modules
import qs.components
import qs.preferences
import qs.services

Item {
    id: root
    height: 25
    width: pills.implicitWidth + 20

    Behavior on width {
        NumberAnimation {
            duration: Appearance.animation.fast;
            easing.type: Appearance.animation.easing
        }
    }

    property bool verticalMode: false

    transform: Rotation {
        origin.x: width / 2
        origin.y: height / 2
        angle: verticalMode ? 90 : 0
    }

    Rectangle {
        id: bgRect
        opacity: !Preferences.keepBarOpaque && !Hyprland.currentWorkspace.hasTilingWindow() ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }

        anchors.fill: parent
        color: Appearance.colors.m3surface_container
        radius: 20
    }

    Row {
        id: pills
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: Hyprland.fullWorkspaces

            delegate: Rectangle {
                id: pill
                width: focused ? 20 : 10
                height: 10
                radius: 20
                anchors.verticalCenter: parent.verticalCenter
                opacity: focused ? 1.0 : 0.4
                color: focused ? Appearance.colors.m3primary : Appearance.colors.m3on_surface

                Behavior on width { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
                Behavior on opacity { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
                Behavior on color { ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (Hyprland.activeWsId !== id) Hyprland.dispatch(`workspace ${id}`)
                }
            }
        }
    }

    WheelHandler {
        id: wheel
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        target: root
        property real accumulatedDelta: 0
        property real threshold: 100

        onWheel: (event) => {
            const total = Hyprland.fullWorkspaces.count
            const current = Hyprland.focusedWorkspace.id

            accumulatedDelta += verticalMode ? event.angleDelta.x : event.angleDelta.y

            if (Math.abs(accumulatedDelta) >= threshold) {
                if (accumulatedDelta > 0) {
                    if (current > 1)
                        Hyprland.dispatch("workspace -1")
                } else {
                    if (current < total)
                        Hyprland.dispatch("workspace +1")
                }

                accumulatedDelta = 0
            }

            event.accepted = true
        }
    }
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        hoverEnabled: true

        onClicked: {
            if (popout.isVisible)
                popout.hide()
            else
                popout.show()
        }
    }
    HoverHandler {
        id: hover
    }
    StyledPopout {
        id: popout
        hoverTarget: hover
        interactable: true
        hCenterOnItem: true
        requiresHover: false
        Component {
            WorkspacePreview {}
        }
    }
}
