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

    property color barColor: Colors.darken(Colors.accent, 0.1)
    property color backgroundColor: "transparent"
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

    ClippingRectangle {
        id: background
        anchors.fill: parent
        radius: 100
        color: root.backgroundColor

        RowLayout {
            anchors.centerIn: parent
            spacing: 10
            MaterialSymbol {
                icon: {
                    if (root.value === 0) return "volume_off"
                    else if (root.value <= 30) return "volume_mute"
                    else if (root.value <= 70) return "volume_down"
                    else return "volume_up"
                }
                font.pixelSize: 24
                color: Colors.foreground
            }

            Text {
                text: root.labelText
                font.pixelSize: 14
                color: Colors.foreground
            }
        }

        Rectangle {
            id: bar
            clip: true
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: root.width * Math.min(Math.max(value, 0), 100) / 100
            color: root.barColor

            Behavior on width {
                enabled: !root.dragging
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            RowLayout {
                x: (root.width - width) / 2
                y: (root.height - height) / 2
                spacing: 10
                MaterialSymbol {
                    icon: {
                        if (root.value === 0) return "volume_off"
                        else if (root.value <= 50) return "volume_down"
                        else return "volume_up"
                    }
                    font.pixelSize: 24
                    color: Colors.foreground
                }

                Text {
                    text: root.labelText
                    font.pixelSize: 14
                    color: Colors.foreground
                }
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
