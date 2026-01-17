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
    property bool captureError: false
    property string captureErrorMessage: ""

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
            root.captureError = false;
            root.captureErrorMessage = "";
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
                    root.captureError = true;
                    root.captureErrorMessage = "failed to freeze screen";
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

        onExited: (code, status) => {
            if (code !== 0) {
                root.debugLog("Freeze process exited with code " + code);
                root.captureError = true;
                root.captureErrorMessage = "screen freeze failed";
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
                root.captureError = true;
                root.captureErrorMessage = "freeze timed out";
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
            property bool isProcessing: false
            property bool windowMode: false

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

            function captureFullscreen() {
                root.debugLog("Capturing fullscreen");
                captureWindow.isProcessing = true;
                whiskerCapture.command = ["whisker", "screen", "capture", "--source=" + root.frozenImagePath, "--copy"];
                whiskerCapture.running = true;
            }

            function captureWindow(windowRect) {
                root.debugLog("Capturing window: " + windowRect.x + "," + windowRect.y + " " + windowRect.width + "x" + windowRect.height);
                captureWindow.isProcessing = true;
                const regionX = Math.floor(windowRect.x);
                const regionY = Math.floor(windowRect.y);
                const regionW = Math.floor(windowRect.width);
                const regionH = Math.floor(windowRect.height);
                whiskerCapture.command = ["whisker", "screen", "capture", "--source=" + root.frozenImagePath, "--region=" + regionX + "," + regionY + "_" + regionW + "x" + regionH, "--copy"];
                whiskerCapture.running = true;
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

                    captureWindow.isProcessing = true;
                    whiskerCapture.command = ["whisker", "screen", "capture", "--source=" + root.frozenImagePath, "--region=" + regionX + "," + regionY + "_" + regionW + "x" + regionH, "--copy"];

                    root.debugLog("Executing: " + whiskerCapture.command.join(" "));
                    whiskerCapture.running = true;
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

                onExited: (code, status) => {
                    root.debugLog("Capture process exited with code " + code);
                    if (code !== 0) {
                        root.captureError = true;
                        if (root.captureErrorMessage === "") {
                            root.captureErrorMessage = "capture failed";
                        }
                        errorMessage.visible = true;
                        errorCloseTimer.start();
                    } else {
                        root.debugLog("Capture successful, starting close animation");
                        captureWindow.closeWithAnimation();
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
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_F) {
                        captureWindow.captureFullscreen();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_W) {
                        captureWindow.windowMode = !captureWindow.windowMode;
                        event.accepted = true;
                    }
                }

                Rectangle {
                    id: errorMessage
                    visible: root.captureError
                    anchors.centerIn: parent
                    width: errorText.width + 40
                    height: errorText.height + 30
                    color: Appearance.colors.m3error
                    radius: 12

                    StyledText {
                        id: errorText
                        anchors.centerIn: parent
                        font.pixelSize: 16
                        color: Appearance.colors.m3on_error
                        text: "an error occurred while trying to capture\n" + root.captureErrorMessage + "\n\npress escape to close"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Timer {
                        id: errorCloseTimer
                        interval: 5000
                        repeat: false
                        onTriggered: {
                            captureWindow.closeWithAnimation();
                        }
                    }
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
                    visible: !root.captureError

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
                    visible: !root.captureError
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
                                root.captureError = true;
                                root.captureErrorMessage = "failed to load screen image";
                                errorMessage.visible = true;
                                errorCloseTimer.start();
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

                        Rectangle {
                            x: selectionArea.selectionX
                            y: selectionArea.selectionY
                            width: selectionArea.selectionWidth
                            height: selectionArea.selectionHeight
                            color: "black"
                            opacity: captureWindow.isProcessing ? 0.6 : 0
                            visible: captureWindow.isProcessing

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.InOutQuad
                                }
                            }

                            LoadingIcon {
                                anchors.centerIn: parent
                                visible: captureWindow.isProcessing
                            }
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
                        enabled: captureWindow.isRegionMode && captureWindow.uiReady && !captureWindow.windowMode

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

                    // window mode overlays
                    Repeater {
                        model: {
                            if (!captureWindow.windowMode || !captureWindow.uiReady)
                                return [];

                            var workspace = Hyprland.focusedMonitor?.activeWorkspace;
                            if (!workspace?.toplevels)
                                return [];

                            return workspace.toplevels.values;
                        }

                        delegate: Item {
                            required property var modelData
                            property var win: modelData?.lastIpcObject
                            visible: win?.at && win?.size

                            property real barOffsetX: Preferences.verticalBar() ? Appearance.barSize : 0
                            property real barOffsetY: Preferences.horizontalBar() ? Appearance.barSize : 0
                            property real scaleX: screenContainer.width / (captureWindow.screen.width - barOffsetX)
                            property real scaleY: screenContainer.height / (captureWindow.screen.height - barOffsetY)

                            x: visible ? (win.at[0] - barOffsetX) * scaleX : 0
                            y: visible ? (win.at[1] - barOffsetY) * scaleY : 0
                            width: visible ? win.size[0] * scaleX : 0
                            height: visible ? win.size[1] * scaleY : 0
                            z: win?.floating ? (hoverArea.containsMouse ? 1000 : 100) : (hoverArea.containsMouse ? 50 : 0)

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: Appearance.colors.m3primary
                                border.width: hoverArea.containsMouse ? 3 : 0
                                radius: 8
                                Behavior on border.width {
                                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: Appearance.colors.m3primary
                                opacity: hoverArea.containsMouse ? 0.15 : 0
                                radius: 8
                                Behavior on opacity {
                                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                                }
                            }

                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    captureWindow.captureWindow(Qt.rect(win.at[0], win.at[1], win.size[0], win.size[1]));
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
                            root.captureError = false;
                            if (root.lastReported !== "") {
                                Quickshell.execDetached({
                                    command: ["whisker", "notify", "Screenshot taken", "Saved to " + root.lastReported]
                                });
                            }
                        }
                    }
                }

                Item {
                    id: actionContainer
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: 30
                    }
                    width: actionRow.width + 20
                    height: actionRow.height + 20
                    Rectangle {
                        anchors.fill: parent
                        color: Appearance.colors.m3surface
                        radius: Appearance.rounding.large
                    }
                    RowLayout {
                        id: actionRow
                        anchors.centerIn: parent
                        StyledButton {
                            icon: "fullscreen"
                            text: "Full screen"
                            tooltipText: "Capture the whole screen [F]"
                            onClicked: captureWindow.captureFullscreen()
                        }
                        Rectangle { Layout.fillHeight: true; width: 2; color: Appearance.colors.m3on_surface_variant; opacity: 0.2 }
                        StyledButton {
                            icon: "window"
                            checkable: true
                            checked: captureWindow.windowMode
                            text: "Window"
                            tooltipText: "Hover and click a window to capture it [W]"
                            onClicked: {
                                captureWindow.windowMode = !captureWindow.windowMode;
                            }
                        }
                        StyledButton {
                            secondary: true
                            icon: "close"
                            tooltipText: "Exit [Escape]"
                            onClicked: captureWindow.closeWithAnimation()
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
