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

    property color barColor: Colors.accent
    property color backgroundColor: Colors.opacify(Colors.accent, 0.2)
    readonly property string labelText: value.toFixed(0) + "%"
    border {
        width: 1
        color: Colors.darken(Colors.accent, 0)
    }
    function updateBrightness() {
        const val = Math.round(value)
        Qt.callLater(() => {
            applyProc.command = ["sh", "-c", `brightnessctl set ${val}%`]
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
            root.updateBrightness()
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
                icon: "brightness_5"
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
                    easing.type: Easing.OutCubic
                }
            }

            RowLayout {
                x: (root.width - width) / 2
                y: (root.height - height) / 2
                spacing: 10
                MaterialSymbol {
                    icon: "brightness_7"
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
        brightnessReadProc.running = true
    }

    Process {
        id: brightnessReadProc
        command: ["sh", "-c", "brightnessctl get && brightnessctl max"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n');
                if (lines.length >= 2) {
                    const current = parseInt(lines[0])
                    const maximum = parseInt(lines[1])
                    if (!isNaN(current) && !isNaN(maximum) && maximum > 0) {
                        const percent = (current / maximum) * 100
                        root.value = percent
                    }
                }
            }
        }
    }


}
