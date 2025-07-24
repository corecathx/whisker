import Quickshell.Hyprland
import QtQuick
import QtQml.Models
import QtQuick.Layouts
import qs.modules
import Quickshell.Hyprland
import QtQuick
import QtQml.Models
import QtQuick.Layouts
import qs.modules

Item {
    id: root
    width: 400
    height: 30
    property string countshit: ""
    Row {
        id: pillRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        Text {
            color: Colors.foreground
            text: root.countshit
        }
        Repeater {
            model: {
                var workspaces = Hyprland.workspaces.values;
                var count = workspaces.length;

                // Ensure at least 3 workspaces
                if (count < 3) {
                    for (i in workspaces) {
                        root.countshit = i.id
                    }
                    for (var i = 3-count; i <= 3; i++) {
                        workspaces.push({ focused: false }); // Add placeholder workspaces
                    }
                }
                return workspaces;
            }

            Rectangle {
                required property HyprlandWorkspace modelData

                id: pill
                width: modelData.focused ? 20 : 10
                height: 20
                radius: 100
                anchors.verticalCenter: parent.verticalCenter

                color: modelData.focused ? Colors.foreground : Colors.opacify(Colors.darken(Colors.foreground, 0.5), 0.9)
                Text {
                    
                    anchors.centerIn: parent
                    text: modelData.id
                }
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
            }
        }
    }
}
