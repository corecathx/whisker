import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.modules


PanelWindow {
    anchors {
        top: true
        left: true
        bottom: true
        right: true
    }
    
    color: "transparent"

    mask: Region {}
    WlrLayershell.layer: WlrLayer.Background
    Corners {
        cornerType: "inverted"
        cornerHeight: 20
        color: Appearance.panel_color
        corners: [0,1,2,3]
    }
}