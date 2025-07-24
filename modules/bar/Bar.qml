// Bar.qml
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules
import qs.preferences

Scope {
    id: root
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id:root
            property var modelData
            screen: modelData

            anchors {
              top: ShellLayout.bar_position === 'top'
              bottom: ShellLayout.bar_position === 'bottom'
              left: true
              right: true
            }

            implicitHeight: 55

            Item {
                anchors.fill: parent

                BarLeft {
                    anchors.left: parent.left
                    
                    anchors.verticalCenter: parent.verticalCenter
                    
                    anchors.leftMargin: 40
                }

                BarRight {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 40
                }

                BarMiddle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }


          color: Appearance.panel_color
        }
    }
}
