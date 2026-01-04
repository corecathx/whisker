pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
import qs.modules
import qs.components

Scope {
    id: root
    property bool active: false
    property rect selectedRegion: Qt.rect(0, 0, 0, 0)
    property string frozenImagePath: ""
    property string lastReported: ""
    property real captureStartTime: 0
    property bool freezeImageReady: false

    function debugLog(message) {
        return;
        Log.info("windows/screencapture/Screencapture.qml", "Debug - " + message);
    }

    IpcHandler {
        target: "screen"
        function record() {
            root.debugLog("Record requested (not implemented)");
            Log.info("windows/screencapture/Screencapture.qml", "implement recording later");
        }
        function capture() {
            if (root.active) {
                root.debugLog("Capture already in progress, ignoring request");
                return;
            }

            root.debugLog("Initiating capture...");
            root.captureStartTime = Date.now();
            root.lastReported = "";
            root.freezeImageReady = false;
            freezeProcess.running = true;
        }
    }

    Process {
        id: freezeProcess
        command: ["whisker", "screen", "freeze"]
        stdout: StdioCollector {
            onStreamFinished: {
                const freezeDuration = ((Date.now() - root.captureStartTime) / 1000).toFixed(1);
                root.frozenImagePath = text.trim();
                root.debugLog("Screen freeze completed in " + freezeDuration + "s");
                root.debugLog("Frozen image path: " + root.frozenImagePath);

                if (root.frozenImagePath === "") {
                    root.debugLog("ERROR: Empty frozen image path!");
                    return;
                }

                root.active = true;
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "") {
                    root.debugLog("Freeze process stderr: " + text.trim());
                }
            }
        }
    }

    Timer {
        id: freezeTimeout
        interval: 10000
        running: freezeProcess.running
        repeat: false
        onTriggered: {
            if (freezeProcess.running) {
                root.debugLog("ERROR: Freeze process timed out after 10s");
                freezeProcess.running = false;
                root.active = false;
            }
        }
    }

    LazyLoader {
        active: root.active
        component: PanelWindow {
            id: captureWindow
            property bool isClosing: false
            property bool isRegionMode: true
            property bool uiReady: false
            property real uiReadyTime: 0

            color: Appearance.colors.m3surface
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "whisker:screencapture"

            Component.onCompleted: {
                root.debugLog("Capture window created");
            }

            function closeWithAnimation() {
                if (isClosing) {
                    root.debugLog("Close already in progress, skipping");
                    return;
                }

                root.debugLog("Starting close animation");
                isClosing = true;
                zoomInAnim.start();
            }

            function captureRegion() {
                if (!root.freezeImageReady) {
                    root.debugLog("ERROR: Attempted capture before image ready!");
                    return;
                }

                if (!captureWindow.uiReady) {
                    root.debugLog("ERROR: Attempted capture before UI ready!");
                    return;
                }

                if (selectionArea.hasSelection) {
                    const regionX = Math.floor(root.selectedRegion.x);
                    const regionY = Math.floor(root.selectedRegion.y);
                    const regionW = Math.floor(root.selectedRegion.width);
                    const regionH = Math.floor(root.selectedRegion.height);

                    root.debugLog("Capturing region: " + regionX + "," + regionY + " " + regionW + "x" + regionH);

                    whiskerCapture.command = ["whisker", "screen", "capture", "--source=" + root.frozenImagePath, "--region=" + regionX + "," + regionY + "_" + regionW + "x" + regionH, "--copy"];

                    root.debugLog("Executing: " + whiskerCapture.command.join(" "));
                    whiskerCapture.running = true;
                    closeWithAnimation();
                } else {
                    root.debugLog("No valid selection to capture");
                }
            }

            Process {
                id: whiskerCapture
                stdout: StdioCollector {
                    onStreamFinished: {
                        root.lastReported = text.trim();
                        const totalDuration = ((Date.now() - root.captureStartTime) / 1000).toFixed(1);
                        root.debugLog("Capture completed in " + totalDuration + "s total");
                        if (root.lastReported !== "") {
                            root.debugLog("Saved to: " + root.lastReported);
                        }
                    }
                }

                stderr: StdioCollector {
                    onStreamFinished: {
                        if (text.trim() !== "") {
                            root.debugLog("Capture process stderr: " + text.trim());
                        }
                    }
                }
            }

            Item {
                anchors.fill: parent
                focus: true
                Keys.onEscapePressed: {
                    root.debugLog("Escape pressed, canceling capture");
                    Quickshell.execDetached({
                        command: []
                    });
                    captureWindow.closeWithAnimation();
                }

                Image {
                    id: wallpaper
                    anchors.fill: parent
                    source: Appearance.wallpaper
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    cache: true
                    opacity: 0
                    scale: 1

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 1.0
                        blurMax: 64
                        brightness: -0.1
                    }

                    onStatusChanged: {
                        if (status === Image.Ready) {
                            root.debugLog("Wallpaper loaded, starting fade-in");
                            fadeInAnim.start();
                        } else if (status === Image.Error) {
                            root.debugLog("ERROR: Wallpaper failed to load");
                        }
                    }
                }

                NumberAnimation {
                    id: fadeInAnim
                    target: wallpaper
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Appearance.animation.medium
                    easing.type: Appearance.animation.easing
                }

                Item {
                    id: screenContainer
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowOpacity: 1
                        shadowColor: Appearance.colors.m3shadow
                        shadowBlur: 1
                        shadowScale: 1
                    }
                    anchors.centerIn: parent
                    width: captureWindow.width
                    height: captureWindow.height

                    Image {
                        id: frozenScreen
                        anchors.fill: parent
                        source: root.frozenImagePath !== "" ? ("file://" + root.frozenImagePath) : ""
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        cache: false
                        asynchronous: false

                        onStatusChanged: {
                            if (status === Image.Loading) {
                                root.debugLog("Loading frozen screen image...");
                            } else if (status === Image.Ready) {
                                const loadTime = ((Date.now() - root.captureStartTime) / 1000).toFixed(1);
                                root.debugLog("Frozen screen image ready (" + loadTime + "s total)");
                                root.freezeImageReady = true;

                                uiReadyTimer.start();
                            } else if (status === Image.Error) {
                                root.debugLog("ERROR: Failed to load frozen screen image!");
                                captureWindow.closeWithAnimation();
                            }
                        }
                    }

                    Timer {
                        id: uiReadyTimer
                        interval: Appearance.animation.medium + 50
                        repeat: false
                        onTriggered: {
                            captureWindow.uiReady = true;
                            captureWindow.uiReadyTime = Date.now();
                            const readyTime = ((Date.now() - root.captureStartTime) / 1000).toFixed(1);
                            root.debugLog("UI ready for interaction (" + readyTime + "s total)");
                        }
                    }

                    Item {
                        id: darkerItem
                        anchors.fill: parent
                        visible: (selectionArea.hasSelection || selectionArea.isSelecting) && captureWindow.isRegionMode

                        Rectangle {
                            x: 0
                            y: 0
                            width: parent.width
                            height: selectionArea.selectionY
                            color: "black"
                            opacity: 0.5
                        }
                        Rectangle {
                            x: 0
                            y: selectionArea.selectionY + selectionArea.selectionHeight
                            width: parent.width
                            height: parent.height - (selectionArea.selectionY + selectionArea.selectionHeight)
                            color: "black"
                            opacity: 0.5
                        }
                        Rectangle {
                            x: 0
                            y: selectionArea.selectionY
                            width: selectionArea.selectionX
                            height: selectionArea.selectionHeight
                            color: "black"
                            opacity: 0.5
                        }
                        Rectangle {
                            x: selectionArea.selectionX + selectionArea.selectionWidth
                            y: selectionArea.selectionY
                            width: parent.width - (selectionArea.selectionX + selectionArea.selectionWidth)
                            height: selectionArea.selectionHeight
                            color: "black"
                            opacity: 0.5
                        }
                    }

                    Rectangle {
                        id: outlineItem
                        x: selectionArea.selectionX
                        y: selectionArea.selectionY
                        width: selectionArea.selectionWidth
                        height: selectionArea.selectionHeight
                        color: "transparent"
                        border.color: Appearance.colors.m3primary
                        border.width: 2
                        visible: (selectionArea.isSelecting || selectionArea.hasSelection) && captureWindow.isRegionMode
                    }

                    Rectangle {
                        visible: selectionArea.isSelecting
                        anchors.top: outlineItem.bottom
                        anchors.topMargin: 10
                        anchors.horizontalCenter: outlineItem.horizontalCenter
                        implicitWidth: innerText.width + 10
                        implicitHeight: innerText.height + 10
                        color: Appearance.colors.m3surface
                        radius: 20
                        StyledText {
                            id: innerText
                            anchors.centerIn: parent
                            font.pixelSize: 14
                            color: Appearance.colors.m3on_surface
                            property real scaleX: screenContainer.width / captureWindow.width
                            property real scaleY: screenContainer.height / captureWindow.height
                            text: Math.floor(selectionArea.selectionX / innerText.scaleX) + ", " + Math.floor(selectionArea.selectionY / innerText.scaleY) + " " + Math.floor(selectionArea.selectionWidth / innerText.scaleX) + "x" + Math.floor(selectionArea.selectionHeight / innerText.scaleY)
                        }
                    }

                    MouseArea {
                        id: selectionArea
                        anchors.fill: parent
                        enabled: captureWindow.isRegionMode && captureWindow.uiReady

                        property real startX: 0
                        property real startY: 0
                        property real endX: 0
                        property real endY: 0
                        property bool isSelecting: false
                        property bool hasSelection: false

                        property real selectionXPercent: 0
                        property real selectionYPercent: 0
                        property real selectionWidthPercent: 0
                        property real selectionHeightPercent: 0

                        property real selectionX: selectionXPercent * parent.width
                        property real selectionY: selectionYPercent * parent.height
                        property real selectionWidth: selectionWidthPercent * parent.width
                        property real selectionHeight: selectionHeightPercent * parent.height

                        onPressed: mouse => {
                            if (!captureWindow.uiReady) {
                                root.debugLog("Selection blocked: UI not ready");
                                return;
                            }

                            startX = Math.max(0, Math.min(mouse.x, width));
                            startY = Math.max(0, Math.min(mouse.y, height));
                            endX = startX;
                            endY = startY;
                            isSelecting = true;
                            hasSelection = false;
                            root.debugLog("Selection started at " + Math.floor(startX) + "," + Math.floor(startY));
                        }

                        onPositionChanged: mouse => {
                            if (isSelecting) {
                                endX = Math.max(0, Math.min(mouse.x, width));
                                endY = Math.max(0, Math.min(mouse.y, height));
                                selectionXPercent = Math.min(startX, endX) / width;
                                selectionYPercent = Math.min(startY, endY) / height;
                                selectionWidthPercent = Math.abs(endX - startX) / width;
                                selectionHeightPercent = Math.abs(endY - startY) / height;
                            }
                        }

                        onReleased: mouse => {
                            if (isSelecting) {
                                endX = Math.max(0, Math.min(mouse.x, width));
                                endY = Math.max(0, Math.min(mouse.y, height));
                                isSelecting = false;

                                const pixelWidth = Math.abs(endX - startX);
                                const pixelHeight = Math.abs(endY - startY);
                                hasSelection = pixelWidth > 5 && pixelHeight > 5;

                                if (hasSelection) {
                                    selectionXPercent = Math.min(startX, endX) / width;
                                    selectionYPercent = Math.min(startY, endY) / height;
                                    selectionWidthPercent = pixelWidth / width;
                                    selectionHeightPercent = pixelHeight / height;

                                    const screenScaleX = captureWindow.screen.width / width;
                                    const screenScaleY = captureWindow.screen.height / height;

                                    root.selectedRegion = Qt.rect(Math.min(startX, endX) * screenScaleX, Math.min(startY, endY) * screenScaleY, pixelWidth * screenScaleX, pixelHeight * screenScaleY);

                                    root.debugLog("Selection completed: " + Math.floor(pixelWidth) + "x" + Math.floor(pixelHeight) + " pixels");

                                    captureWindow.captureRegion();
                                } else {
                                    root.debugLog("Selection too small (" + Math.floor(pixelWidth) + "x" + Math.floor(pixelHeight) + "), canceling");
                                    Quickshell.execDetached({
                                        command: []
                                    });
                                    captureWindow.closeWithAnimation();
                                }
                            }
                        }
                    }

                    ParallelAnimation {
                        id: shrinkAnim
                        running: captureWindow.visible && !captureWindow.isClosing && captureWindow.width > 0 && captureWindow.height > 0 && root.freezeImageReady

                        onRunningChanged: {
                            if (running) {
                                root.debugLog("Starting shrink animation");
                            }
                        }

                        NumberAnimation {
                            target: wallpaper
                            property: "scale"
                            from: wallpaper.scale
                            to: wallpaper.scale + 0.05
                            duration: Appearance.animation.medium
                            easing.type: Appearance.animation.easing
                        }
                        NumberAnimation {
                            target: screenContainer
                            property: "width"
                            from: captureWindow.width
                            to: captureWindow.width * 0.8
                            duration: Appearance.animation.medium
                            easing.type: Appearance.animation.easing
                        }
                        NumberAnimation {
                            target: screenContainer
                            property: "height"
                            from: captureWindow.height
                            to: captureWindow.height * 0.8
                            duration: Appearance.animation.medium
                            easing.type: Appearance.animation.easing
                        }
                    }

                    ParallelAnimation {
                        id: zoomInAnim

                        onStarted: {
                            root.debugLog("Starting zoom-in animation");
                        }

                        NumberAnimation {
                            target: wallpaper
                            property: "scale"
                            from: wallpaper.scale
                            to: wallpaper.scale - 0.05
                            duration: Appearance.animation.medium
                            easing.type: Appearance.animation.easing
                        }
                        NumberAnimation {
                            target: screenContainer
                            property: "width"
                            to: captureWindow.width
                            duration: Appearance.animation.medium
                            easing.type: Appearance.animation.easing
                        }
                        NumberAnimation {
                            target: screenContainer
                            property: "height"
                            to: captureWindow.height
                            duration: Appearance.animation.medium
                            easing.type: Appearance.animation.easing
                        }

                        NumberAnimation {
                            target: darkerItem
                            property: "opacity"
                            from: darkerItem.opacity
                            to: 0
                            duration: Appearance.animation.medium
                            easing.type: Appearance.animation.easing
                        }
                        NumberAnimation {
                            target: outlineItem
                            property: "opacity"
                            from: outlineItem.opacity
                            to: 0
                            duration: Appearance.animation.medium
                            easing.type: Appearance.animation.easing
                        }

                        onFinished: {
                            root.debugLog("Close animation completed");
                            root.active = false;
                            if (root.lastReported !== "") {
                                Quickshell.execDetached({
                                    command: ["whisker", "notify", "Screenshot taken", "Saved to " + root.lastReported]
                                });
                            }
                        }
                    }
                }
            }

            HyprlandFocusGrab {
                id: grab
                windows: [captureWindow]
            }

            onVisibleChanged: {
                if (visible) {
                    root.debugLog("Capture window visible, activating focus grab");
                    grab.active = true;
                }
            }

            Connections {
                target: grab
                function onActiveChanged() {
                    if (!grab.active && !captureWindow.isClosing) {
                        root.debugLog("Focus lost, closing capture window");
                        Quickshell.execDetached({
                            command: []
                        });
                        captureWindow.closeWithAnimation();
                    }
                }
            }
        }
    }
}
