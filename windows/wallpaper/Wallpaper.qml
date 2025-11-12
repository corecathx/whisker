import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets
import Quickshell.Wayland
import qs.modules
import qs.services
import qs.providers
import qs.preferences
import qs.components
import qs.components.effects
import qs.components.players
import QtQuick.Layouts
import QtQuick.Effects
import QtMultimedia

PanelWindow {
    id: wallpaper
    property string fallbackWallpaper: Utils.getPath("images/fallback-wallpaper.png")
    property string currentWallpaper: Appearance.wallpaper !== "" ? Appearance.wallpaper : fallbackWallpaper
    property bool isVideo: Utils.isVideo(currentWallpaper)

    property real widgetOffset: 40
    property real screenOffset: 50

    property bool barIsShowing: !Preferences.bar.autoHide || Globals.isBarHovered
    property real wallpaperShift: (Preferences.bar.autoHide && barIsShowing) ? widgetOffset * 0.6 : 0
    property real widgetShift: barIsShowing ? widgetOffset + screenOffset : widgetOffset

    anchors {
        left: true
        bottom: true
        top: true
        right: true
    }
    color: Appearance.colors.m3surface
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "whisker:wallpaper"
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    onCurrentWallpaperChanged: {
        var newIsVideo = Utils.isVideo(currentWallpaper);
        var wasVideo = isVideo;

        if (wasVideo) {
            oldVideo.source = currentVideo.source;
            oldVideo.opacity = 1;
            oldVideo.play();
            oldVideoFadeOut.start();
        } else {
            oldImage.source = currentImage.source;
            oldImage.opacity = 1;
            oldImageFadeOut.start();
        }

        isVideo = newIsVideo;

        if (newIsVideo) {
            var wp = currentWallpaper;
            currentVideo.source = wp.startsWith("file://") ? wp : "file://" + wp;
            currentVideo.opacity = 0;
        } else {
            currentImage.source = currentWallpaper;
            currentImage.opacity = 0;
        }
    }

    Item {
        id: wallpaperWrapper
        clip: true
        anchors.fill: parent

        anchors.leftMargin: Preferences.bar.position === "left" ? wallpaperShift : 0
        anchors.rightMargin: Preferences.bar.position === "right" ? wallpaperShift : 0
        anchors.topMargin: (Preferences.bar.position === "top" && !Preferences.bar.small) ? wallpaperShift : 0
        anchors.bottomMargin: (Preferences.bar.position === "bottom" && !Preferences.bar.small) ? wallpaperShift : 0

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: Appearance.animation.medium
                easing.type: Appearance.animation.easing
            }
        }
        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: Appearance.animation.medium
                easing.type: Appearance.animation.easing
            }
        }
        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: Appearance.animation.medium
                easing.type: Appearance.animation.easing
            }
        }
        Behavior on anchors.bottomMargin {
            NumberAnimation {
                duration: Appearance.animation.medium
                easing.type: Appearance.animation.easing
            }
        }

        Image {
            id: currentImage
            anchors.fill: parent
            sourceSize: Qt.size(wallpaper.width, wallpaper.height)
            source: ""
            fillMode: Image.PreserveAspectCrop
            smooth: true
            cache: true
            visible: !isVideo
            opacity: 1

            Component.onCompleted: {
                if (!isVideo)
                    source = currentWallpaper;
            }
        }

        Video {
            id: currentVideo
            anchors.fill: parent
            source: ""
            autoPlay: true
            loops: MediaPlayer.Infinite
            muted: true
            fillMode: VideoOutput.PreserveAspectCrop
            visible: isVideo
            opacity: 1

            function updatePlayback() {
                if (!isVideo) {
                    stop();
                    return;
                }

                if (Hyprland.currentWorkspace.hasTilingWindow()) {
                    if (playbackState === MediaPlayer.PlayingState)
                        pause();
                } else {
                    if (playbackState !== MediaPlayer.PlayingState)
                        play();
                }
            }

            Connections {
                target: Hyprland
                function onWorkspaceUpdated() {
                    currentVideo.updatePlayback();
                }
            }

            Component.onCompleted: {
                if (isVideo) {
                    var wp = currentWallpaper;
                    source = wp.startsWith("file://") ? wp : "file://" + wp;
                }
                updatePlayback();
            }
        }

        Image {
            id: oldImage
            anchors.fill: parent
            sourceSize: Qt.size(wallpaper.width, wallpaper.height)
            source: ""
            fillMode: Image.PreserveAspectCrop
            smooth: true
            cache: true
            opacity: 0

            NumberAnimation {
                id: oldImageFadeOut
                target: oldImage
                property: "opacity"
                duration: Appearance.animation.medium
                easing.type: Appearance.animation.easing
                from: 1
                to: 0

                onStopped: {
                    oldImage.source = "";
                    if (!isVideo) {
                        newImageFadeIn.start();
                    } else {
                        newVideoFadeIn.start();
                    }
                }
            }
        }

        Video {
            id: oldVideo
            anchors.fill: parent
            source: ""
            autoPlay: false
            loops: MediaPlayer.Infinite
            muted: true
            fillMode: VideoOutput.PreserveAspectCrop
            opacity: 0

            NumberAnimation {
                id: oldVideoFadeOut
                target: oldVideo
                property: "opacity"
                duration: Appearance.animation.medium
                easing.type: Appearance.animation.easing
                from: 1
                to: 0

                onStopped: {
                    oldVideo.stop();
                    oldVideo.source = "";
                    if (!isVideo) {
                        newImageFadeIn.start();
                    } else {
                        newVideoFadeIn.start();
                    }
                }
            }
        }

        NumberAnimation {
            id: newImageFadeIn
            target: currentImage
            property: "opacity"
            duration: Appearance.animation.medium
            easing.type: Appearance.animation.easing
            from: 0
            to: 1
        }

        NumberAnimation {
            id: newVideoFadeIn
            target: currentVideo
            property: "opacity"
            duration: Appearance.animation.medium
            easing.type: Appearance.animation.easing
            from: 0
            to: 1
        }

        CavaVisualizer {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: {
                if (Preferences.bar.small)
                    return 0;
                if (Preferences.bar.position === "bottom" && barIsShowing)
                    return screenOffset - 15 - wallpaperShift;
                return 0;
            }
            Behavior on anchors.bottomMargin {
                NumberAnimation {
                    duration: Appearance.animation.fast
                    easing.type: Appearance.animation.easing
                }
            }
            visible: !Hyprland.currentWorkspace.hasTilingWindow()
        }

        Item {
            id: lyricsBox
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Preferences.bar.position === "bottom" ? widgetShift : widgetOffset
            width: content.implicitWidth + 40
            height: content.implicitHeight + 20

            visible: lyrics.status === "FETCHING" || lyrics.status === "LOADED"

            Behavior on width {
                NumberAnimation {
                    duration: Appearance.animation.medium
                    easing.type: Appearance.animation.easing
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: Appearance.animation.medium
                    easing.type: Appearance.animation.easing
                }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowOpacity: 1
                shadowColor: Appearance.colors.m3shadow
                shadowBlur: 1
                shadowScale: 1
            }

            LrclibProvider {
                id: lyrics
                currentArtist: Players.active?.trackArtist.replace(" - Topic", "")
                currentTrack: Players.active?.trackTitle
                currentPosition: Players.active.position * 1000
                Component.onCompleted: fetchLyrics()
            }

            Rectangle {
                anchors.fill: parent
                color: Appearance.colors.m3surface
                radius: 20
            }

            ColumnLayout {
                id: content
                anchors.centerIn: parent

                LoadingIcon {
                    Layout.alignment: Qt.AlignHCenter
                    visible: lyrics.status === "FETCHING"
                }

                StyledText {
                    id: mainLyric
                    visible: lyrics.status === "LOADED" && text !== ""
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 24
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Appearance.animation.fast
                            easing.type: Appearance.animation.easing
                        }
                    }
                }

                StyledText {
                    id: subLyric
                    Layout.alignment: Qt.AlignHCenter
                    color: Appearance.colors.m3on_surface_variant
                    font.pixelSize: 16
                    visible: lyrics.status === "LOADED" && text !== ""
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Appearance.animation.fast
                            easing.type: Appearance.animation.easing
                        }
                    }
                }
            }

            Connections {
                target: lyrics
                function onReady() {
                    lyricsBox.updateLyrics();
                }
                function onCurrentLineIndexChanged() {
                    lyricsBox.fadeOutAndUpdate();
                }
            }

            function updateLyrics() {
                const current = lyrics.currentLineIndex;
                mainLyric.text = lyrics.lyricsData[current]?.text || "";
                subLyric.text = lyrics.lyricsData[current]?.translation || "";
            }

            function fadeOutAndUpdate() {
                mainLyric.opacity = 0;
                subLyric.opacity = 0;
                updateTimer.restart();
            }

            Timer {
                id: updateTimer
                interval: Appearance.animation.fast
                onTriggered: {
                    lyricsBox.updateLyrics();
                    Qt.callLater(() => {
                        mainLyric.opacity = 1;
                        subLyric.opacity = 1;
                    });
                }
            }
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        anchors.leftMargin: Preferences.bar.position === "left" ? widgetShift : widgetOffset
        anchors.bottomMargin: Preferences.bar.position === "bottom" ? widgetShift : widgetOffset

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
