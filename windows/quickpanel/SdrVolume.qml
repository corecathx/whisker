import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.components
import qs.modules

Rectangle {
    id: root
    color: "transparent"
    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 20

    property real value: 50

    property color barColor: Appearance.colors.m3primary
    property color backgroundColor: Colors.opacify(Appearance.colors.m3primary, 0.2)
    readonly property string labelText: value.toFixed(0) + "%"

    function updateVolume() {
        const val = Math.round(value)
        Qt.callLater(() => {
            applyProc.command = ["sh", "-c", `pactl set-sink-volume @DEFAULT_SINK@ ${val}%`]
            applyProc.running = true
        })
    }

    property bool dragging: false

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onPressed: {
            root.dragging = false
            updateFromMouse(mouse.x)
        }

        onPositionChanged: {
            root.dragging = true
            if (mouse.buttons & Qt.LeftButton)
                updateFromMouse(mouse.x)
        }

        onReleased: root.dragging = false

        function updateFromMouse(xPos) {
            root.value = Math.max(0, Math.min(100, xPos / root.width * 100))
            root.updateVolume()
        }
    }

    Rectangle {
        height: 10
        color: root.backgroundColor
        anchors.verticalCenter: parent.verticalCenter
        radius: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: parent.height*0.5
        anchors.rightMargin: parent.height*0.5
    }
    Rectangle {
        id: background
        anchors.fill: parent
        radius: 100
        color: "transparent"

        Rectangle {
            id: bar
            radius: 20
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: root.height + (root.width - root.height) * Math.min(Math.max(value, 0), 100) / 100
            color: root.barColor

            Behavior on width {
                enabled: !root.dragging
                NumberAnimation {
                    duration: 200
                    easing.type: Appearance.animation.easing
                }
            }
            MaterialIcon {
                icon: {
                    if (root.value === 0) return "volume_off"
                    else if (root.value <= 50) return "volume_down"
                    else return "volume_up"
                }
                font.pixelSize: 24
                color: Appearance.colors.m3on_primary
                anchors.right: parent.width > parent.height ? parent.right : undefined
                anchors.left: parent.width > parent.height ? undefined : parent.left
                anchors.centerIn: parent.width > parent.height ? undefined : parent
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: parent.width > parent.height ? 10 : 0
            }
        }
    }

    Process {
        id: applyProc
    }

    Component.onCompleted: {
        volumeReadProc.running = true
    }

    Process {
        id: volumeReadProc
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | head -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const vol = parseInt(text.trim())
                if (!isNaN(vol)) root.value = vol
            }
        }
    }
}
