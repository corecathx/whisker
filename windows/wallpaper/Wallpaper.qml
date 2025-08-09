import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Wayland
import qs.modules
import QtMultimedia
PanelWindow {
    id: wallpaper
    anchors {
        top: true
        left: true
        bottom: true
        right: true
    }

    color: Colors.darken(Appearance.colors.m3surface, 0.2);
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    Image {
        id: bgImage
        anchors.fill: parent
        source: Appearance.wallpaper
        fillMode: Image.PreserveAspectCrop
        smooth: true
        cache: true
    }

    // Video {
    //     anchors.fill: parent
    //     autoPlay: true
    //     smooth: false
    //     loops: 9999
    //     source: "file:///home/corecat/Downloads/output2.mp4"
    // }
}
