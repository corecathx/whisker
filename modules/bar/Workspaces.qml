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
            duration: Appearance.anim_fast;
            easing.type: Easing.OutExpo
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
        Behavior on opacity { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo } }

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
                               
                Behavior on width { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo } }
                Behavior on opacity { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo } }
                Behavior on color { ColorAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo } }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (Hyprland.activeWsId !== id) Hyprland.dispatch(`workspace ${id}`)
                }
            }
        }
    }

    HoverHandler {
        id: hover
    }

    StyledPopout {
        hoverTarget: hover
        interactable: true
        hCenterOnItem: true
        Component {
            WorkspacePreview {}
        }
    }
}
