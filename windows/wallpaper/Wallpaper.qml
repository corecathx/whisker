import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Io
import qs.modules
import qs.services
import qs.preferences
import qs.components
import qs.components.effects
import qs.components.players
import QtQuick.Layouts
import QtQuick.Effects

Scope {
    id: root

    property string fallbackWallpaper: Utils.getPath("images/fallback-wallpaper.png")
    property string currentWallpaper: Appearance.wallpaper !== "" ? Appearance.wallpaper : fallbackWallpaper
    property bool isVideo: Utils.isVideo(currentWallpaper)
    property var mpvpaperProcesses: []

    IpcHandler {
        target: "wallpaper"

        function reload() {
            root.reloadWallpaper();
        }
    }

    function reloadWallpaper() {
        var newWallpaper = Appearance.wallpaper !== ""
            ? Appearance.wallpaper
            : root.fallbackWallpaper;

        if (newWallpaper === root.currentWallpaper) {
            if (root.isVideo)
                root.startMpvpaper();

            return;
        }

        root.currentWallpaper = newWallpaper;
    }

    function startMpvpaper() {
        if (!root.isVideo)
            return;

        root.stopMpvpaper();

        var monitors = Hyprland.monitors?.values || [];

        Log.info(
            "windows/wallpaper/Wallpaper.qml",
            "Starting mpvpaper for " + monitors.length + " monitors"
        );

        monitors.forEach(monitor => {
            if (!monitor || !monitor.name)
                return;

            var proc = mpvpaperComponent.createObject(root, {
                monitorName: monitor.name,
                videoPath: root.currentWallpaper
            });

            if (proc)
                root.mpvpaperProcesses.push(proc);
        });
    }

    function stopMpvpaper() {
        root.mpvpaperProcesses.forEach(proc => {
            if (!proc)
                return;

            proc.running = false;
            proc.destroy();
        });

        root.mpvpaperProcesses = [];
    }

    onCurrentWallpaperChanged: {
        var newIsVideo = Utils.isVideo(root.currentWallpaper);

        if (root.isVideo)
            root.stopMpvpaper();

        root.isVideo = newIsVideo;

        if (newIsVideo)
            root.startMpvpaper();
    }

    Component.onCompleted: {
        if (root.isVideo)
            root.startMpvpaper();
    }

    Component {
        id: mpvpaperComponent

        Process {
            id: mpvProc

            property string monitorName: ""
            property string videoPath: ""

            command: [
                "mpvpaper",
                "-o",
                "no-audio loop",
                monitorName,
                videoPath
            ]

            running: true

            stderr: SplitParser {
                onRead: data => {
                    console.error(
                        "[mpvpaper:" + mpvProc.monitorName + " ERROR]",
                        data.trim()
                    );
                }
            }

            onRunningChanged: {
                if (!running) {
                    Log.info(
                        "windows/wallpaper/Wallpaper.qml",
                        "[mpvpaper:" + monitorName + "] Process stopped"
                    );
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: wallpaper

            property var modelData
            screen: modelData

            property string fallbackWallpaper: root.fallbackWallpaper
            property string currentWallpaper: root.currentWallpaper
            property bool isVideo: root.isVideo

            property real widgetOffset: 40
            property real screenOffset: 50

            property bool barIsShowing: !Preferences.bar.autoHide || Globals.isBarHovered
            property real wallpaperShift: (Preferences.bar.autoHide && barIsShowing) ? widgetOffset * 0.3 : 0
            property real widgetShift: barIsShowing ? widgetOffset + screenOffset : widgetOffset

            anchors {
                left: true
                bottom: true
                top: true
                right: true
            }

            color: "transparent"

            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "whisker:wallpaper"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            Item {
                id: wallpaperWrapper
                anchors.fill: parent

                transform: Translate {
                    x: {
                        if (Preferences.bar.position === "left")
                            return wallpaperShift;
                        if (Preferences.bar.position === "right")
                            return -wallpaperShift;
                        return 0;
                    }

                    y: {
                        if (Preferences.bar.position === "top")
                            return wallpaperShift;
                        if (Preferences.bar.position === "bottom")
                            return -wallpaperShift;
                        return 0;
                    }

                    Behavior on x {
                        NumberAnimation {
                            duration: Appearance.animation.medium
                            easing.type: Appearance.animation.easing
                        }
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: Appearance.animation.medium
                            easing.type: Appearance.animation.easing
                        }
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

                    scale: Preferences.bar.autoHide ? 1.025 : 1

                    Behavior on scale {
                        NumberAnimation {
                            duration: Appearance.animation.fast
                            easing.type: Appearance.animation.easing
                        }
                    }

                    Component.onCompleted: {
                        if (!isVideo)
                            source = currentWallpaper;
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
                            newImageFadeIn.start();
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

                Lyrics {
                    id: lyricsBox

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Preferences.bar.position === "bottom"
                        ? widgetShift
                        : widgetOffset

                    visible: Preferences.widgets.showLyrics
                        && !Preferences.widgets.lyricsAsOverlay
                        && !Hyprland.currentWorkspace.hasTilingWindow()
                }
            }

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                anchors.bottom: parent.bottom

                anchors.leftMargin: Preferences.bar.position === "left"
                    ? widgetShift
                    : widgetOffset

                anchors.bottomMargin: Preferences.bar.position === "bottom"
                    ? widgetShift
                    : widgetOffset

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

                RowLayout {
                    visible: Preferences.widgets.desktop.clock

                    StyledText {
                        Layout.alignment: Qt.AlignCenter
                        text: Qt.formatDateTime(Time.date, "HH")
                        font.family: "Outfit Black"
                        color: Appearance.colors.m3primary
                        font.pixelSize: 96
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignCenter
                        text: ":"
                        font.family: "Outfit Black"
                        color: Appearance.colors.m3error
                        font.pixelSize: 96
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignCenter
                        text: Qt.formatDateTime(Time.date, "mm")
                        font.family: "Outfit Black"
                        color: Appearance.colors.m3secondary
                        font.pixelSize: 96
                    }
                }

                StyledText {
                    text: Qt.formatDateTime(Time.date, "dddd, dd/MM")
                    color: Appearance.colors.m3primary
                    font.pixelSize: 32
                    font.bold: true
                    visible: Preferences.widgets.desktop.clock
                }

                PlayerDisplay {
                    visible: Preferences.widgets.desktop.player && !!Players.active
                    Layout.topMargin: 20
                    Layout.minimumWidth: 400
                }

                layer.enabled: true

                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowOpacity: 1
                    shadowColor: Appearance.colors.m3shadow
                    shadowBlur: 0.5
                }
            }

            onCurrentWallpaperChanged: {
                var newIsVideo = Utils.isVideo(currentWallpaper);

                if (!newIsVideo) {
                    oldImage.source = currentImage.source;
                    oldImage.opacity = 1;
                    oldImageFadeOut.start();

                    currentImage.source = currentWallpaper;
                    currentImage.opacity = 0;
                }
            }
        }
    }
}