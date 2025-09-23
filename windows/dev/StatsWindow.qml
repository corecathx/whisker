import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.modules
import qs.components

PanelWindow {
    id: win
    visible: true
    color: "transparent"
    anchors {
        top: true
        left: true
    }

    function lerp(a, b, t) {
        return a + (b - a) * t;
    }

    // FPS tracker data
    property var frameTimes: []
    property int fps: 0
    property real displayedFps: 0.0

    ColumnLayout {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20
        anchors.topMargin: 20

        RowLayout {
            spacing: 0
            Text {
                id: fpsInt
                color: win.displayedFps < 30 ? Appearance.colors.m3error : Appearance.colors.m3on_surface
                text: Math.floor(win.displayedFps)  // integer part
                font.pixelSize: 18
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
            }
            Text {
                id: fpsDecimal
                color: win.displayedFps < 30 ? Appearance.colors.m3error : Appearance.colors.m3on_surface
                text: (win.displayedFps % 1).toFixed(1).substring(1) + " FPS" // decimal part + FPS
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
                anchors.bottom: fpsInt.bottom
            }
        }
    }

    FrameAnimation {
        id: frameAnim
        running: true
        onTriggered: {
            const now = Date.now()
            win.frameTimes.push(now)

            while (win.frameTimes.length > 0 && now - win.frameTimes[0] > 1000)
                win.frameTimes.shift()

            win.fps = win.frameTimes.length
            win.displayedFps = win.lerp(win.displayedFps, win.fps, 0.2)
        }
    }
}
