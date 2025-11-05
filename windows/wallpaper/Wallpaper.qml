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
import qs.components.players
import QtQuick.Layouts
import QtQuick.Effects
import QtMultimedia

PanelWindow {
    id: wallpaper
    property real widgetOffset: 40
    property real screenOffset: 50

    property bool barIsShowing: !Preferences.autoHideBar || Globals.isBarHovered
    property real wallpaperShift: (Preferences.autoHideBar && barIsShowing) ? widgetOffset * 0.6 : 0
    property real widgetShift: barIsShowing ? widgetOffset + screenOffset : widgetOffset

    anchors {
        left: true
        bottom: true
        top: true
        right: true
    }
    color: Appearance.colors.m3surface
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: 'whisker:wallpaper'
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    Item {
        id: wallpaperWrapper
        clip: true
        anchors.fill: parent

        anchors.leftMargin: Preferences.barPosition === 'left' ? wallpaperShift : 0
        anchors.rightMargin: Preferences.barPosition === 'right' ? wallpaperShift : 0
        anchors.topMargin: (Preferences.barPosition === 'top' && !Preferences.smallBar) ? wallpaperShift : 0
        anchors.bottomMargin: (Preferences.barPosition === 'bottom' && !Preferences.smallBar) ? wallpaperShift : 0

        Behavior on anchors.leftMargin { NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing } }
        Behavior on anchors.rightMargin { NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing } }
        Behavior on anchors.topMargin { NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing } }
        Behavior on anchors.bottomMargin { NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing } }

        Image {
            id: oldWallpaper
            sourceSize: Qt.size(wallpaper.width, wallpaper.height)
            anchors.centerIn: parent
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
                duration: Appearance.animation.slow * 2
                easing.type: Appearance.animation.easing
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
                sourceSize: Qt.size(wallpaper.width, wallpaper.height)
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
                    return
                }

                if (Hyprland.currentWorkspace.hasTilingWindow()) {
                    if (video.playbackState === MediaPlayer.PlayingState)
                        video.pause()
                } else {
                    if (video.playbackState !== MediaPlayer.PlayingState)
                        video.play()
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

        Item {
            visible: Preferences.useWallpaper && Appearance.wallpaper === ""
            anchors.fill: parent

            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: Utils.getPath("images/fallback-wallpaper-overlay.png")
                smooth: true
                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1.0
                    colorizationColor: Appearance.colors.m3on_surface_variant
                }
            }

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 60
                spacing: 20

                Rectangle {
                    Layout.fillHeight: true
                    width: 10
                    radius: 20
                    color: Appearance.colors.m3on_surface
                }

                ColumnLayout {
                    StyledText {
                        text: "You got no default wallpaper set!"
                        color: Appearance.colors.m3on_background
                        font.family: "Outfit SemiBold"
                        font.pixelSize: 32
                    }
                    StyledText {
                        text: "Set your wallpaper by opening Whisker Settings!\n(SUPER + I)"
                        color: Appearance.colors.m3on_background
                        font.pixelSize: 24
                    }
                }
            }
        }

        CavaVisualizer {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: {
                if (Preferences.smallBar) return 0
                if (Preferences.barPosition === 'bottom' && barIsShowing)
                    return screenOffset - 15 - wallpaperShift
                return 0
            }
            Behavior on anchors.bottomMargin {
                NumberAnimation {
                    duration: Appearance.animation.fast
                    easing.type: Appearance.animation.easing
                }
            }
            visible: !Hyprland.currentWorkspace.hasTilingWindow()
        }
    }


    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        anchors.leftMargin: Preferences.barPosition === 'left' ? widgetShift : widgetOffset
        anchors.bottomMargin: Preferences.barPosition === 'bottom' ? widgetShift : widgetOffset

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
        Behavior on anchors.bottomMargin {
            NumberAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }

        spacing: -10

        StyledText {
            text: Qt.formatDateTime(Time.date, "HH:mm")
            font.family: "Outfit ExtraBold"
            color: Appearance.colors.m3on_background
            font.pixelSize: 72
        }
        StyledText {
            text: Qt.formatDateTime(Time.date, "dddd, dd/MM")
            color: Appearance.colors.m3on_background
            font.pixelSize: 32
            font.bold: true
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
