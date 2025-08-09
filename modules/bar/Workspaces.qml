import QtQuick
import QtQml.Models
import QtQuick.Layouts
import qs.modules
import qs.services
Item {
    id: root
    width: 400
    height: 30
    property int shown: 3
    readonly property int groupOffset: Math.floor((Hyprland.activeWsId - 1) / shown) * shown
    Row {
        id: pillRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Repeater {
            model: Hyprland.workspaces

            delegate: Rectangle {
                id: pill
                width: modelData.focused ? 20 : 10
                height: 10
                radius: 20
                anchors.verticalCenter: parent.verticalCenter
                border {
                    width: modelData.focused ? 0 : 2
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
                color: modelData.focused ? Appearance.colors.m3on_background : "transparent"
                Behavior on width {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutBack
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 500
                        easing.type: Easing.OutBack
                    }
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
}
