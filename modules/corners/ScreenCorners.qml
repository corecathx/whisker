import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.modules
import qs.modules.overlays
import qs.preferences

PanelWindow {
    anchors {
        top: true
        left: true
        bottom: true
        right: true
    }
    
    color: "transparent"

    mask: Region {}
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: Preferences.smallBar ? ExclusionMode.Ignore : ExclusionMode.Normal
    Corners {
        cornerType: "inverted"
        cornerHeight: 20
        color: "black"
        corners: [0,1,2,3]
    }
}