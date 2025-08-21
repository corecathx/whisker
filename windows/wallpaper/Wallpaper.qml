import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Wayland
import qs.modules
import qs.services
import QtQuick.Layouts
import QtQuick.Effects
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

    Video {
        anchors.fill: parent
        autoPlay: false
        smooth: false
        loops: 9999
        muted: true
        source: "file:///home/corecat/Downloads/lucanimations.mp4"
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 300
        spacing: -10
        Text {
            text: Qt.formatDateTime(Time.date, "HH:mm")
            color: Appearance.colors.m3on_background
            font.pixelSize: 96
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: Qt.formatDateTime(Time.date, "dddd, dd/MM")
            color: Appearance.colors.m3on_background
            font.pixelSize: 32
            Layout.alignment: Qt.AlignHCenter
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true 
            shadowOpacity: 1
            shadowColor: Appearance.colors.m3shadow
            shadowBlur: 2
            shadowScale: 1
        }
    }

}
