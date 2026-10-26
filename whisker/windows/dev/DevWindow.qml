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
import qs.whisker.modules
import qs.whisker.services
import qs.whisker.components
import qs.whisker.components.material
import QtQuick
import qs.whisker.components.misc
import qs.whisker.modules.bar

import qs.whisker.components.animation

Scope {

    Window {
        id: win
        visible: true
        color: "black"



        Rectangle {
            id: rect
            width: 50
            height: 50

            Anim on x { type: Anim.Spring }
            Anim on color { type: Anim.Color }
        }

        Timer {
            running: true
            interval: 1000
            property bool isLeft: false
            repeat: true
            onTriggered: {
                isLeft = !isLeft
                if (isLeft) {
                    rect.x = 50
                    rect.color = 'red'
                }
                else {
                    rect.x = 200
                    rect.color = 'blue'
                }
            }
        }

    }
}