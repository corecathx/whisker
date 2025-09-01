import QtQuick
import QtQml.Models
import QtQuick.Layouts
import qs.modules
import qs.services

Item {
    id: root
    width: Preferences.verticalBar() ? 30 : 400
    height: Preferences.verticalBar() ? 400 : 30

    property int shown: 3
    readonly property int groupOffset: Math.floor((Hyprland.activeWsId - 1) / shown) * shown

    Loader {
        id: layoutLoader
        anchors.centerIn: parent
        sourceComponent: Preferences.verticalBar() ? colLayout : rowLayout
    }

    Component {
        id: rowLayout
        Row {
            id: pillRow
            spacing: 10
            anchors.centerIn: parent

            Repeater {
                model: Hyprland.workspaces
                delegate: pillDelegate
            }
        }
    }

    Component {
        id: colLayout
        Column {
            id: pillColumn
            spacing: 10
            anchors.centerIn: parent

            Repeater {
                model: Hyprland.workspaces
                delegate: pillDelegate
            }
        }
    }

    Component {
        id: pillDelegate
        Rectangle {
            id: pill
            width: Preferences.verticalBar() ? 10 : (modelData.focused ? 20 : 10)
            height: Preferences.verticalBar() ? (modelData.focused ? 20 : 10) : 10
            radius: 20
            opacity: modelData.focused ? 1 : 0.5
            color: Appearance.colors.m3on_background

            Behavior on width {
                NumberAnimation { duration: 500; easing.type: Easing.OutBack }
            }
            Behavior on height {
                NumberAnimation { duration: 500; easing.type: Easing.OutBack }
            }
            Behavior on opacity {
                NumberAnimation { duration: 500; easing.type: Easing.OutBack }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const wsId = index + root.groupOffset + 1;
                    if (Hyprland.activeWsId !== wsId)
                        Hyprland.dispatch(`workspace ${wsId}`);
                }
            }
        }
    }
}
