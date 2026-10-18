import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland

import qs.preferences
import qs.modules
import qs.components
import qs.components.misc
import qs.services

import qs.windows.dock.components

Scope {
    id: root
    property bool dockEnabled: Preferences.widgets.dock.enabled
    IpcHandler {
        target: "launcher"

        function toggle() {
            if (win.state === 1) {
                win.closeLauncher();
                // if (!win.shouldKeepDockVisible)
                //     win.dockVisible = false
            } else {
                win.openLauncher()
            }
        }
    }

    CustomShortcut {
        name: "launcher"
        appid: "whisker"
        description: "Toggle Whisker's launcher."

        onReleased: () => {
            if (win.state === 1) {
                win.closeLauncher();
                // if (!win.shouldKeepDockVisible)
                //     win.dockVisible = false
            } else {
                win.openLauncher()
            }
        }
    }

    PanelWindow {
        id: win

        property real targetLauncherWidth: screen.width * 0.4
        property real targetLauncherHeight: screen.height * 0.6
        property int state: 0 // 0 = dock, 1 = launcher
        onStateChanged: {
            Globals.dockState = win.state
        }
        property real activeMaxTimer: 1000
        property bool dockVisible: false
        property bool shouldKeepDockVisible: {
            if (root.dockEnabled) 
                return !Hyprland.currentWorkspace.hasWindow || !Hyprland.currentWorkspace.hasTilingWindow()
            
            return false
        }
        anchors {
            left: true
            bottom: true
            top: true
            right: true
        }
        WlrLayershell.namespace: 'whisker:dock'
        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Normal
        WlrLayershell.keyboardFocus: state === 1 ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand
        color: 'transparent'

        function showDock() {
            activeTimer.stop()
            dockVisible = true
        }

        function hideDock() {
            if (state == 0 && !hoverTriggerMa.containsMouse && !dockMouseArea.hovered) {
                activeTimer.restart()
            }
        }

        function openLauncher() {
            activeTimer.stop()
            dockVisible = true
            state = 1
            appList.focusToSearch()
        }

        function closeLauncher() {
            state = 0
            appList.closeLauncher()
        }

        mask: Region {
            x: {
                if (win.dockVisible)
                    return Math.min(container.x, hoverTrigger.x)
                return hoverTrigger.x
            }
            y: {
                if (win.dockVisible)
                    return Math.min(container.y, hoverTrigger.y)
                return hoverTrigger.y
            }
            width: {
                if (win.dockVisible)
                    return Math.max(container.x + container.width, hoverTrigger.x + hoverTrigger.width) - x
                return hoverTrigger.width
            }
            height: {
                if (win.dockVisible)
                    return Math.max(container.y + container.height, hoverTrigger.y + hoverTrigger.height) - y
                return hoverTrigger.height
            }
        }

        Timer {
            id: activeTimer
            interval: root.dockEnabled ? win.activeMaxTimer : 0
            onTriggered: {
                if (hoverTriggerMa.containsMouse 
                    || dockMouseArea.hovered 
                    || win.state != 0 
                    || win.shouldKeepDockVisible)
                    return

                win.dockVisible = false
            }
        }

        Connections {
            target: Hyprland

            function onWorkspaceUpdated() {
                if (win.shouldKeepDockVisible) {
                    win.showDock()
                } else {
                    win.hideDock()
                }
            }
        }

        ///// visual objects /////
        Item {
            id: hoverTrigger
            width: container.width + 40
            height: 3
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            // StyledRectangle {
            //     anchors.fill: parent
            //     color: 'red'
            // }
            MouseArea {
                id: hoverTriggerMa
                enabled: root.dockEnabled
                anchors.fill: parent
                hoverEnabled: true

                onContainsMouseChanged: {
                    if (containsMouse)
                        win.showDock()
                    else
                        win.hideDock()
                }
            }
        }

        Item {
            id: container
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: {
                    if (win.dockVisible)
                        return 20

                    if (root.dockEnabled)
                        return -(container.height - 5)
                    
                    return -container.height
                }
                onBottomMarginChanged: {
                    Globals.dockBottomMargin = anchors.bottomMargin
                }
            }
            Behavior on anchors.bottomMargin {
                NumberAnimation {
                    duration: Appearance.animation.fast
                    easing.type: Appearance.animation.easing
                }
            }
            width: containerLayout.width + 30
            height: containerLayout.height + 20
            StyledRectangle {
                id: background
                anchors.fill: parent
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: win.dockVisible
                    shadowColor: Appearance.colors.m3shadow
                    shadowBlur: 1
                }
                color: Appearance.colors.m3surface
                radius: Appearance.rounding.extraLarge
            }

            ColumnLayout {
                id: containerLayout
                anchors.centerIn: parent
                spacing: 10
                LauncherContainer {
                    id: appList
                    Layout.fillWidth: true
                    Layout.topMargin: 5
                    targetWidth: win.targetLauncherWidth 
                    targetHeight: win.targetLauncherHeight
                    window: win

                    onLauncherItemClicked: {
                        console.log("HIDE ON LAUNCHERITEMCLICKED")
                        win.state = 0
                    }
                    Item {
                        anchors.fill: parent
                        focus: win.state === 1

                        Keys.onEscapePressed: {
                            win.state = 0
                        }
                    }
                }
                Row {
                    id: dockLayout
                    visible: root.dockEnabled
                    spacing: 10
                    RowLayout {
                        id: dockItemLayout
                        spacing: 10
                        width: win.state == 1 ? win.targetLauncherWidth : implicitWidth
                        Behavior on width {
                            enabled: win.state == 1 || appList.visible
                            NumberAnimation {
                                duration: Appearance.animation.fast
                                easing.type: Appearance.animation.easing
                            }
                        }
                        Repeater {
                            model: Preferences.widgets.dock.items
                            delegate: DockItem {
                                previewOnTooltip: win.state === 0
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                            height: 20
                        }
                    }
                    StyledRectangle {
                        width: 1
                        height: parent.height - 20
                        anchors.verticalCenter: parent.verticalCenter
                        color: Appearance.colors.m3on_surface_variant
                        opacity: 0.4
                        visible: Preferences.widgets.dock.items.length > 0
                    }
                    Item {
                        width: 50
                        height: 50

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: "apps"
                            font.pixelSize: 28
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (win.state == 0)
                                    win.state = 1
                                else
                                    win.state = 0
                            }
                        }
                    }
                }
            }

            HoverHandler {
                id: dockMouseArea

                onHoveredChanged: {
                    if (hovered)
                        win.showDock()
                    else
                        win.hideDock()
                }
            }
        }
    }
}