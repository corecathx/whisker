import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Greetd

import qs.whisker.components
import qs.whisker.modules

import qs.whisker.windows.greeter.components

Scope {
    id: root
    property bool isGreetdSession: Greetd.available

    PanelWindow {
        id: win
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }
        color: Appearance.colors.m3surface
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        Item {
            id: container
            anchors.fill: parent
            BackgroundLayer {
                id: backgroundLayer
                anchors.fill: parent
                scrollX: mouseArea.targetX
                scrollY: (mouseArea.targetY + (foregroundLayer.selectedUser * 20)) - 50
                progress: foregroundLayer.state == 1 ? 1 : 0
            }
            ForegroundLayer {
                id: foregroundLayer
                anchors.fill: parent
            }
            ControlsLayer {
                id: controlsLayer
                anchors.fill: parent

                showSessionDropdown: foregroundLayer.state == 1
                sessions: foregroundLayer.sessions.map(session => (session.name))
                selectedSession: foregroundLayer.selectedSession

                onSelectedIndexChanged: index => {
                    foregroundLayer.selectedSession = index
                }
            }
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton

            property real targetX: 0
            property real targetY: 0

            onPositionChanged: mouse => {
                targetX = (mouse.x / width - 0.5) * 20
                targetY = (mouse.y / height - 0.5) * 20
            }

            onExited: {
                targetX = 0
                targetY = 0
            }
        }
        StyledButton {
            text: "exit"
            onClicked: Qt.quit()
            secondary: true
            visible: !root.isGreetdSession
            opacity: 0
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 20
        }

    }
}