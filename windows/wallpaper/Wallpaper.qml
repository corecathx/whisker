import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets
import Quickshell.Wayland
import qs.modules
import qs.services
import qs.preferences
import qs.components
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

    color: Appearance.colors.m3surface;
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    Image {
        id: bgImage
        anchors.fill: parent
        source: Appearance.wallpaper
        fillMode: Image.PreserveAspectCrop
        smooth: true
        cache: true
        visible: Preferences.useWallpaper && !Preferences.useVideoWallpaper
    }
    
    RowLayout {
        anchors.centerIn: parent
        visible: Preferences.useWallpaper && Appearance.wallpaper === ""
        spacing: 20
        Image {
            source: Utils.getPath("images/sad-cat.png")
            sourceSize: Qt.size(100,100)
            smooth: true
            Layout.alignment: Qt.AlignVCenter
            layer.enabled: true
            layer.effect: MultiEffect {
                colorization: 1.0
                colorizationColor: Appearance.colors.m3on_surface_variant
            }
        }
        ColumnLayout {
            Text {
                text: "You got no default wallpaper set!"
                color: Appearance.colors.m3on_background
                font.bold: true
                font.pixelSize: 20
                //Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: "Set your wallpaper by pressing SUPER + SHIFT + W!"
                color: Appearance.colors.m3on_background
                font.pixelSize: 14
                //Layout.alignment: Qt.AlignHCenter
            }
        }

    }


    Video {
        id: video
        anchors.fill: parent
        autoPlay: false
        smooth: false
        loops: 9999
        muted: true
        source: "file:///home/corecat/Downloads/lucanimations_vaapi.mp4"

        function updatePlayback() {
            if (!Preferences.useVideoWallpaper) return;
            const workspace = Hyprland.focusedWorkspace
            let hasNonFloatingWindows = Hyprland.currentWorkspace.hasTilingWindow()

            if (hasNonFloatingWindows) {
                if (video.playbackState === MediaPlayer.PlayingState) {
                    video.pause()
                    console.log("Paused video: non-floating window exists")
                }
            } else {
                if (video.playbackState !== MediaPlayer.PlayingState) {
                    video.play()
                    console.log("Resumed video: all windows floating or none")
                }
            }
        }

        Connections {
            target: Hyprland
            function onWorkspaceUpdated() {
                video.updatePlayback()
            }
        }

        Connections {
            target: Preferences

            function onUseVideoWallpaperChanged() {
                console.log("Preferences 'useVideoWallpaper' changed!")
                video.updatePlayback()
            }
        }

        Component.onCompleted: video.updatePlayback()
    }

    ColumnLayout {
        //anchors.horizontalCenter: parent.horizontalCenter
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 40
        anchors.bottomMargin: 40 + (Preferences.barPosition === 'bottom' ? 50 : 0)
        //anchors.topMargin: 300
        spacing: -10
        Text {
            text: Qt.formatDateTime(Time.date, "HH:mm")
            color: Appearance.colors.m3on_background
            font.pixelSize: 72
            font.bold: true
            //Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: Qt.formatDateTime(Time.date, "dddd, dd/MM")
            color: Appearance.colors.m3on_background
            font.pixelSize: 32
            //Layout.alignment: Qt.AlignHCenter
        }
        PlayerDisplay {
            Layout.topMargin: 20
            Layout.minimumWidth: 400
        }
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true 
            shadowOpacity: 1
            shadowColor: Appearance.colors.m3shadow
            shadowBlur: 1
        }
    }
    CavaVisualizer {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: !Hyprland.currentWorkspace.hasTilingWindow()
    }
}
