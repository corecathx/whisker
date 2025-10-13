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

    IpcHandler {
        target: "screen"
        function record() {
            console.log("implement recording later")
        }
        function capture() {
            if (root.active) return
            root.lastReported = ""
            freezeProcess.running = true
        }
    }

    Process {
        id: freezeProcess
        command: ["whisker", "screen", "freeze"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.frozenImagePath = text.trim()
                console.log("Frozen image at:", root.frozenImagePath)
                root.active = true
            }
        }
    }

    LazyLoader {
        active: root.active
        component: PanelWindow {
            id: captureWindow
            property bool isClosing: false
            property bool isRegionMode: true
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

            function closeWithAnimation() {
                if (isClosing) return
                isClosing = true
                zoomInAnim.start()
            }

            function captureRegion() {
                if (selectionArea.hasSelection) {
                    whiskerCapture.command = [
                        "whisker", "screen", "capture",
                        "--source=" + root.frozenImagePath,
                        "--region=" + Math.floor(root.selectedRegion.x) + "," + Math.floor(root.selectedRegion.y)
                            + "_" + Math.floor(root.selectedRegion.width) + "x" + Math.floor(root.selectedRegion.height),
                        "--copy"
                    ]
                    console.log(whiskerCapture.command)
                    whiskerCapture.running = true
                    closeWithAnimation()
                }
            }

            Process {
                id: whiskerCapture
                stdout: StdioCollector {
                    onStreamFinished: {
                        root.lastReported = text.trim()
                    }
                }
            }

            Item {
                anchors.fill: parent
                focus: true
                Keys.onEscapePressed: {
                    Quickshell.execDetached({ command: [] })
                    captureWindow.closeWithAnimation()
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
                        if (status === Image.Ready)
                            fadeInAnim.start()
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
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowOpacity: 1
                        shadowColor: Appearance.colors.m3shadow
                        shadowBlur: 1
                        shadowScale: 1
                    }
                    id: screenContainer
                    anchors.centerIn: parent
                    width: captureWindow.width
                    height: captureWindow.height

                    Image {
                        id: frozenScreen
                        anchors.fill: parent
                        source: "file://" + root.frozenImagePath
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        cache: false
                    }

                    Item {
                        id: darkerItem
                        anchors.fill: parent
                        visible: (selectionArea.hasSelection || selectionArea.isSelecting) && captureWindow.isRegionMode

                        Rectangle { x: 0; y: 0; width: parent.width; height: selectionArea.selectionY; color: "black"; opacity: 0.5 }
                        Rectangle { x: 0; y: selectionArea.selectionY + selectionArea.selectionHeight; width: parent.width; height: parent.height - (selectionArea.selectionY + selectionArea.selectionHeight); color: "black"; opacity: 0.5 }
                        Rectangle { x: 0; y: selectionArea.selectionY; width: selectionArea.selectionX; height: selectionArea.selectionHeight; color: "black"; opacity: 0.5 }
                        Rectangle { x: selectionArea.selectionX + selectionArea.selectionWidth; y: selectionArea.selectionY; width: parent.width - (selectionArea.selectionX + selectionArea.selectionWidth); height: selectionArea.selectionHeight; color: "black"; opacity: 0.5 }
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
                            text: Math.floor(selectionArea.selectionX / innerText.scaleX) + ", " +
                                  Math.floor(selectionArea.selectionY / innerText.scaleY) + " " +
                                  Math.floor(selectionArea.selectionWidth / innerText.scaleX) + "x" +
                                  Math.floor(selectionArea.selectionHeight / innerText.scaleY)
                        }
                    }

                    MouseArea {
                        id: selectionArea
                        anchors.fill: parent
                        enabled: captureWindow.isRegionMode

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

                        onPressed: (mouse) => {
                            startX = Math.max(0, Math.min(mouse.x, width))
                            startY = Math.max(0, Math.min(mouse.y, height))
                            endX = startX
                            endY = startY
                            isSelecting = true
                            hasSelection = false
                        }

                        onPositionChanged: (mouse) => {
                            if (isSelecting) {
                                endX = Math.max(0, Math.min(mouse.x, width))
                                endY = Math.max(0, Math.min(mouse.y, height))
                                selectionXPercent = Math.min(startX, endX) / width
                                selectionYPercent = Math.min(startY, endY) / height
                                selectionWidthPercent = Math.abs(endX - startX) / width
                                selectionHeightPercent = Math.abs(endY - startY) / height
                            }
                        }

                        onReleased: (mouse) => {
                            if (isSelecting) {
                                endX = Math.max(0, Math.min(mouse.x, width))
                                endY = Math.max(0, Math.min(mouse.y, height))
                                isSelecting = false

                                const pixelWidth = Math.abs(endX - startX)
                                const pixelHeight = Math.abs(endY - startY)
                                hasSelection = pixelWidth > 5 && pixelHeight > 5

                                if (hasSelection) {
                                    selectionXPercent = Math.min(startX, endX) / width
                                    selectionYPercent = Math.min(startY, endY) / height
                                    selectionWidthPercent = pixelWidth / width
                                    selectionHeightPercent = pixelHeight / height

                                    root.selectedRegion = Qt.rect(
                                        Math.min(startX, endX) * captureWindow.screen.width / width,
                                        Math.min(startY, endY) * captureWindow.screen.height / height,
                                        pixelWidth * captureWindow.screen.width / width,
                                        pixelHeight * captureWindow.screen.height / height
                                    )

                                    captureWindow.captureRegion()
                                } else {
                                    Quickshell.execDetached({ command: [] })
                                    captureWindow.closeWithAnimation()
                                }
                            }
                        }
                    }

                    ParallelAnimation {
                        id: shrinkAnim
                        running: captureWindow.visible && !captureWindow.isClosing
                        NumberAnimation { target: wallpaper; property: "scale"; from: wallpaper.scale; to: wallpaper.scale + 0.05; duration: Appearance.animation.medium; easing.type: Appearance.animation.easing }
                        NumberAnimation { target: screenContainer; property: "width"; from: captureWindow.width; to: captureWindow.width * 0.8; duration: Appearance.animation.medium; easing.type: Appearance.animation.easing }
                        NumberAnimation { target: screenContainer; property: "height"; from: captureWindow.height; to: captureWindow.height * 0.8; duration: Appearance.animation.medium; easing.type: Appearance.animation.easing }
                    }

                    ParallelAnimation {
                        id: zoomInAnim
                        NumberAnimation { target: wallpaper; property: "scale"; from: wallpaper.scale; to: wallpaper.scale - 0.05; duration: Appearance.animation.medium; easing.type: Appearance.animation.easing }
                        NumberAnimation { target: screenContainer; property: "width"; to: captureWindow.width; duration: Appearance.animation.medium; easing.type: Appearance.animation.easing }
                        NumberAnimation { target: screenContainer; property: "height"; to: captureWindow.height; duration: Appearance.animation.medium; easing.type: Appearance.animation.easing }

                        NumberAnimation { target: darkerItem; property: "opacity"; from: darkerItem.opacity; to: 0; duration: Appearance.animation.medium; easing.type: Appearance.animation.easing }
                        NumberAnimation { target: outlineItem; property: "opacity"; from: outlineItem.opacity; to: 0; duration: Appearance.animation.medium; easing.type: Appearance.animation.easing }

                        onFinished: {
                            root.active = false
                            if (root.lastReported !== "") {
                                Quickshell.execDetached({
                                    command: ["whisker", "notify", "Screenshot taken", "Saved to " + root.lastReported]
                                })
                            }
                        }
                    }
                }
            }

            HyprlandFocusGrab {
                id: grab
                windows: [captureWindow]
            }

            onVisibleChanged: if (visible) grab.active = true

            Connections {
                target: grab
                function onActiveChanged() {
                    if (!grab.active && !captureWindow.isClosing) {
                        Quickshell.execDetached({ command: [] })
                        captureWindow.closeWithAnimation()
                    }
                }
            }
        }
    }
}
