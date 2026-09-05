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
import qs.components.material
import QtQuick
import qs.components.misc
import qs.modules.bar
Scope {

    Window {
        id: win
        visible: true
        color: "black"



        Battery {
            anchors.centerIn: parent
        }


    }
}