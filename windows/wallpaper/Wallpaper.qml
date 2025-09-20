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
        left: true
        bottom: true
        top: true
        right: true
    }
    color: Appearance.colors.m3surface
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    Image {
        id: oldWallpaper
        anchors.fill: parent
        source: Appearance.wallpaper
        fillMode: Image.PreserveAspectCrop
        smooth: true
        cache: true
        visible: Preferences.useWallpaper && !Preferences.useVideoWallpaper
    }

    ClippingRectangle {
        id: animClip
        anchors.centerIn: parent
        width: 0
        height: width
        radius: width
        color: "transparent"
        layer.smooth: true

        NumberAnimation {
            id: revealAnim
            target: animClip
            property: "width"
            duration: Appearance.anim_slow*2
            easing.type: Easing.OutCubic
            from: 0
            to: Math.max(wallpaper.width, wallpaper.height) * 1.2
            onStopped: {
                oldWallpaper.source = newWallpaper.source
                newWallpaper.source = ""
                animClip.width = 0
            }
        }

        Image {
            id: newWallpaper
            anchors.centerIn: parent
            width: wallpaper.width
            height: wallpaper.height
            source: ""
            fillMode: Image.PreserveAspectCrop
            smooth: true
            cache: true
        }
    }

    Connections {
        target: Appearance
        function onWallpaperChanged() {
            newWallpaper.source = Appearance.wallpaper
            delayTimer.start()
        }
    }

    Timer {
        id: delayTimer
        interval: 500
        repeat: false
        onTriggered: revealAnim.start()
    }

    Video {
        id: video
        anchors.fill: parent
        autoPlay: false
        smooth: false
        loops: 9999
        muted: true
        source: "file:///home/corecat/Downloads/lucanimations_vaapi.mp4"
        visible: Preferences.useVideoWallpaper

        function updatePlayback() {
            if (!Preferences.useVideoWallpaper) {
                video.stop()
                return;
            }

            const workspace = Hyprland.focusedWorkspace
            let hasNonFloatingWindows = Hyprland.currentWorkspace.hasTilingWindow()

            if (hasNonFloatingWindows) {
                if (video.playbackState === MediaPlayer.PlayingState) {
                    video.pause()
                }
            } else {
                if (video.playbackState !== MediaPlayer.PlayingState) {
                    video.play()
                }
            }
        }

        Connections {
            target: Hyprland
            function onWorkspaceUpdated() { video.updatePlayback() }
        }
        Connections {
            target: Preferences
            function onUseVideoWallpaperChanged() { video.updatePlayback() }
        }

        Component.onCompleted: video.updatePlayback()
    }

    CavaVisualizer { 
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: (Preferences.barPosition === 'bottom' && !Preferences.smallBar ? 50 : 0)
        visible: !Hyprland.currentWorkspace.hasTilingWindow()
    } 
    
    ColumnLayout { 
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 40 + (Preferences.barPosition === 'left' ? 60 : 0)
        anchors.bottomMargin: 40 + (Preferences.barPosition === 'bottom' ? 50 : 0) 
        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: Appearance.anim_fast
                easing.type: Easing.OutCubic
            }
        }
        Behavior on anchors.bottomMargin {
            NumberAnimation {
                duration: Appearance.anim_fast
                easing.type: Easing.OutCubic
            }
        }
        //anchors.topMargin: 300 
        spacing: -10 
        Text { 
            text: Qt.formatDateTime(Time.date, "HH:mm")
            font.family: "Outfit ExtraBold"
            color: Appearance.colors.m3on_background
            font.pixelSize: 72
            //Layout.alignment: Qt.AlignHCenter 
        } 
        Text { 
            text: Qt.formatDateTime(Time.date, "dddd, dd/MM")
            color: Appearance.colors.m3on_background
            font.pixelSize: 32 
            font.bold: true
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
}
