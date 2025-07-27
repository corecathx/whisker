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
                radius: 100
                anchors.verticalCenter: parent.verticalCenter

                color: modelData.focused ? Colors.foreground : Colors.opacify(Colors.darken(Colors.foreground, 0.5), 0.9)
                Behavior on width {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutQuad
                    }
                }
                
                Behavior on color {
                    ColorAnimation { duration: 250 }
                }

                Behavior on x {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutQuad
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
