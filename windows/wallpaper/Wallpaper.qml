import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Wayland
import qs.modules
PanelWindow {
    id: wallpaper
    anchors {
        top: true
        left: true
        bottom: true
        right: true
    }

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    Rectangle {
        anchors.fill: parent
        color: Colors.darken(Colors.background, 0.2);
        visible: bgImage.source === ""
    }

    Image {
        id: bgImage
        anchors.fill: parent
        source: Appearance.wallpaper
        fillMode: Image.PreserveAspectCrop
        smooth: true
        cache: true
    }
}
