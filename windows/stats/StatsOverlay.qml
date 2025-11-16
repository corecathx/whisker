import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.modules
import qs.components

PanelWindow {
    id: win
    visible: true
    implicitWidth: 500
    implicitHeight: screen.height
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    anchors {
        top: true
        left: true
    }
    margins.top: 20
    margins.left: 20
    mask: Region {
        x: wawa.x
        y: wawa.x
        width: wawa.width
        height: wawa.height
    }
    FPSOverlay {
        id: wawa
    }
}
