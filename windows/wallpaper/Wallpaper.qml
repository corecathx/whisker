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

    // Video {
    //     anchors.fill: parent
    //     autoPlay: true
    //     smooth: false
    //     loops: 9999
    //     source: "file:///home/corecat/Downloads/output2.mp4"
    // }
}
