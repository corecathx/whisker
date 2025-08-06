import QtQuick
import Quickshell
import qs.modules
import qs.services
import qs.preferences
import qs.modules.corners
import qs.components
Item {
    id: root
    property bool inLockScreen: false
    implicitHeight: 50
    anchors.fill: parent
    Corners {
        visible: !root.inLockScreen
        anchors.fill: undefined
        anchors.left: barContainer.right
        cornerType: "cubic"
        cornerHeight: root.implicitHeight
        color: Appearance.panel_color
        corners: [1]
        transform: Scale {
            yScale: Preferences.barPosition === 'top' ? 1 : -1
            origin.y: Preferences.barPosition === 'top' ? 0 : height/2
        }
    }
    Item {
        id: barContainer
        implicitHeight: root.implicitHeight
        width: Preferences.smallBar ? screen?.width - Preferences.barPadding * 2 : parent?.width ?? 0
        anchors {
            horizontalCenter: parent.horizontalCenter
            //fill: !Preferences.smallBar ? parent : undefined
        }

        Rectangle {
            id: panelBackground
            anchors.fill: parent
            color: !inLockScreen ? Appearance.panel_color : "transparent"
        }
        CavaVisualizer {
            multiplier: 0.25
            visible: Mpris.active && !inLockScreen
            anchors.fill: parent
            anchors {
                leftMargin: !Preferences.smallBar ? 40 : 0
                rightMargin: !Preferences.smallBar ? 40 : 0
                bottom: panelBackground.bottom
                horizontalCenter: parent.horizontalCenter
            }
        }

        Item {
            anchors.fill: parent

            BarLeft {
                inLockScreen: root.inLockScreen
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 40
            }

            BarRight {
                inLockScreen: root.inLockScreen
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 40
            }

            BarMiddle {
                visible: !root.inLockScreen
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
    Corners {
        visible: !root.inLockScreen
        anchors.fill: undefined
        anchors.right: barContainer.left
        cornerType: "cubic"
        cornerHeight: root.implicitHeight
        color: Appearance.panel_color
        corners: [0]
        transform: Scale {
            yScale: Preferences.barPosition === 'top' ? 1 : -1
            origin.y: Preferences.barPosition === 'top' ? 0 : height/2
        }
    }
}
