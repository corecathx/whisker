import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Effects
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

Scope {
    id: root

    property string fallbackWallpaper: Utils.getPath("images/fallback-wallpaper.png")
    readonly property string currentWallpaper: Appearance.wallpaper !== "" ? Appearance.wallpaper : fallbackWallpaper
    readonly property bool isVideo: Utils.isVideo(currentWallpaper)
    property bool previousIsVideo: isVideo
    property int reloadRevision: 0

    property real widgetOffset: 40
    property real screenOffset: 50

    property bool barIsShowing: !Preferences.bar.autoHide || Globals.isBarHovered
    property real wallpaperShift: (Preferences.bar.autoHide && barIsShowing) ? widgetOffset * 0.3 : 0
    property real widgetShift: barIsShowing ? widgetOffset + screenOffset : widgetOffset

    // mpvpaper processes
    property var mpvpaperProcesses: []

    IpcHandler {
        target: "wallpaper"
        function reload() {
            root.reloadRevision += 1;
            root.syncWallpaperState();
        }
    }

    onCurrentWallpaperChanged: {
        syncWallpaperState();
    }

    Component.onCompleted: {
        if (isVideo) {
            startMpvpaperForAllMonitors();
        }
    }

    function startMpvpaperForAllMonitors() {
        if (!isVideo)
            return;

        stopAllMpvpaper();

        var monitors = Hyprland.monitors?.values || [];
        Log.info("windows/wallpaper/Wallpaper.qml", "Starting mpvpaper for " + monitors.length + " monitors");

        monitors.forEach(monitor => {
            if (monitor && monitor.name) {
                startMpvpaperForMonitor(monitor.name);
            }
        });
    }

    function startMpvpaperForMonitor(monitorName) {
        Log.info("windows/wallpaper/Wallpaper.qml", "Starting mpvpaper for monitor: " + monitorName);

        var proc = mpvpaperComponent.createObject(root, {
            "monitorName": monitorName,
            "videoPath": currentWallpaper
        });

        if (proc) {
            mpvpaperProcesses.push(proc);
        }
    }

    function stopAllMpvpaper() {
        Log.info("windows/wallpaper/Wallpaper.qml", "Stopping all mpvpaper processes");

        mpvpaperProcesses.forEach(proc => {
            if (proc) {
                proc.running = false;
                proc.destroy();
            }
        });

        mpvpaperProcesses = [];
    }

    function syncWallpaperState() {
        var newIsVideo = Utils.isVideo(currentWallpaper);
        var wasVideo = previousIsVideo;

        if (wasVideo) {
            stopAllMpvpaper();
        }

        previousIsVideo = newIsVideo;

        if (newIsVideo) {
            startMpvpaperForAllMonitors();
        }
    }

    Component {
        id: mpvpaperComponent

        Process {
            id: mpvProc
            property string monitorName: ""
            property string videoPath: ""

            command: ["mpvpaper", "-o", "no-audio loop", monitorName, videoPath]
            running: true

            stdout: SplitParser {
                onRead: data => {
                // console.log("[mpvpaper:" + mpvProc.monitorName + "]", data.trim());
                }
            }

            stderr: SplitParser {
                onRead: data => {
                    console.error("[mpvpaper:" + mpvProc.monitorName + " ERROR]", data.trim());
                }
            }

            onRunningChanged: {
                if (!running) {
                    Log.info("windows/wallpaper/Wallpaper.qml", "[mpvpaper:" + monitorName + "] Process stopped");
                }
            }
        }
    }

    Connections {
        target: Hyprland
        function onWorkspaceUpdated() {
            updateMpvpaperPlayback();
        }
    }

    function updateMpvpaperPlayback() {
        if (!isVideo)
            return;

        var hasTiling = Hyprland.currentWorkspace.hasTilingWindow();
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: wallpaper
            property var modelData
            property string currentWallpaper: root.currentWallpaper
            property bool isVideo: root.isVideo
            property bool previousIsVideo: isVideo
            property int reloadRevision: root.reloadRevision

            screen: modelData
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

            onCurrentWallpaperChanged: {
                applyWallpaperChange();
            }

            onReloadRevisionChanged: {
                applyWallpaperChange();
            }

            function applyWallpaperChange() {
                var newIsVideo = Utils.isVideo(currentWallpaper);
                var wasVideo = previousIsVideo;

                if (!wasVideo) {
                    oldImage.source = currentImage.source;
                    oldImage.opacity = 1;
                    oldImageFadeOut.start();
                }

                previousIsVideo = newIsVideo;

                if (newIsVideo) {
                    currentImage.opacity = 0;
                } else {
                    currentImage.source = currentWallpaper;
                    currentImage.opacity = 0;
                }
            }

            Item {
                id: wallpaperWrapper
                anchors.fill: parent

                transform: Translate {
                    x: {
                        if (Preferences.bar.position === "left") return root.wallpaperShift;
                        if (Preferences.bar.position === "right") return -root.wallpaperShift;
                        return 0;
                    }
                    y: {
                        if (Preferences.bar.position === "top") return root.wallpaperShift;
                        if (Preferences.bar.position === "bottom") return -root.wallpaperShift;
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
                    visible: !wallpaper.isVideo
                    opacity: 1

                    scale: Preferences.bar.autoHide ? 1.025 : 1
                    Behavior on scale { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
                    Component.onCompleted: {
                        if (!wallpaper.isVideo)
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
                        if (Preferences.bar.position === "bottom" && root.barIsShowing)
                            return root.screenOffset - 15 - root.wallpaperShift;
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
                    anchors.bottomMargin: Preferences.bar.position === "bottom" ? root.widgetShift : root.widgetOffset
                    visible: Preferences.widgets.showLyrics && !Preferences.widgets.lyricsAsOverlay && !Hyprland.currentWorkspace.hasTilingWindow()
                }
            }

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                anchors.bottom: parent.bottom

                anchors.leftMargin: Preferences.bar.position === "left" ? root.widgetShift : root.widgetOffset
                anchors.bottomMargin: Preferences.bar.position === "bottom" ? root.widgetShift : root.widgetOffset

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
                    color: Appearance.colors.m3primary
                    font.pixelSize: 72
                    visible: Preferences.widgets.desktop.clock
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
        }
    }
}
