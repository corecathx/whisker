import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import qs.modules
import qs.services
import qs.components

Scope {
    AbsolutePanelWindow {
        id: win

        implicitWidth: 600
        implicitHeight: 400
        color: "transparent"

        ScreencopyView {
            id: background

            captureSource: Quickshell.screens[0]
            live: true

            width: Quickshell.screens[0].width
            height: Quickshell.screens[0].height
            x: -win.position.x
            y: -win.position.y
        }

        // MultiEffect {

        //     source: background
        //     width: Quickshell.screens[0].width
        //     height: Quickshell.screens[0].height
        //     x: -win.position.x
        //     y: -win.position.y
        //     blurEnabled: true
        //     blur: 1
        //     blurMax: 16
        //     blurMultiplier: 1
        // }

        DragHandler {
            target: null

            property point startPos

            onActiveChanged: {
                if (active)
                    startPos = win.position
            }

            onTranslationChanged: {
                if (!active)
                    return

                win.position = Qt.point(
                    startPos.x + translation.x,
                    startPos.y + translation.y
                )
            }
        }
    }
}