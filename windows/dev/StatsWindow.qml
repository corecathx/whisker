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
    width: wawa.width+40
    color: "transparent"
    anchors {
        top: true
        left: true
    }

    function lerp(a, b, t) {
        return a + (b - a) * t;
    }

    property var frameTimes: []
    property int fps: 0
    property real displayedFps: 0.0

    ColumnLayout {
        id: wawa
        spacing: 0
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
        Text {
            id: bottomTxt
            color: Appearance.colors.m3on_surface
            text: "Whisker (DevMode)"
            font.pixelSize: 14
            font.family: "JetBrainsMono Nerd Font"
            anchors.bottom: fpsInt.bottom
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
