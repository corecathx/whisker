import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules
import qs.preferences
import qs.modules.bar.vertical
import QtQuick.Effects
import qs.services

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            property var modelData
            screen: modelData
            property bool shouldShow: !Preferences.bar.autoHide && !Hyprland.focusedWorkspace.hasFullscreen
            property bool isAnimating: false

            exclusionMode: {
                if (shouldShow)
                    return ExclusionMode.Auto;
                return ExclusionMode.Ignore;
            }
            exclusiveZone: 1

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: 'whisker:bar'
            color: "transparent"

            mask: Region {
                id: maskRegion

                x: {
                    if (!Preferences.bar.autoHide)
                        return 0;
                    return Globals.isBarHovered ? 0 : hoverZone.x;
                }
                y: {
                    if (!Preferences.bar.autoHide)
                        return 0;
                    Globals.isBarHovered ? 0 : hoverZone.y;
                }
                width: {
                    if (!Preferences.bar.autoHide)
                        return window.width;
                    return Globals.isBarHovered ? window.width : hoverZone.width;
                }

                height: {
                    if (!Preferences.bar.autoHide)
                        return window.height;
                    return Globals.isBarHovered ? window.height : hoverZone.height;
                }
            }

            anchors {
                top: Preferences.bar.position === 'top' || Preferences.verticalBar()
                bottom: Preferences.bar.position === 'bottom' || Preferences.verticalBar()
                left: Preferences.bar.position === 'left' || Preferences.horizontalBar()
                right: Preferences.bar.position === 'right' || Preferences.horizontalBar()
            }

            implicitHeight: barLoader.item ? barLoader.item.implicitHeight : 0
            implicitWidth: barLoader.item ? barLoader.item.implicitWidth : 0

            function updateHoverState() {
                if (!Preferences.bar.autoHide) {
                    Globals.isBarHovered = false;
                    return;
                }

                const hovering = hover.hovered || barHover.hovered;

                if (hovering) {
                    hideDelay.stop();
                    shouldShow = true;
                    Globals.isBarHovered = true;
                } else {
                    hideDelay.restart();
                }
            }

            Connections {
                target: Preferences.bar
                function onAutoHideChanged() {
                    shouldShow = !Preferences.bar.autoHide && !Hyprland.focusedWorkspace.hasFullscreen;
                }
            }

            Connections {
                target: Hyprland.focusedWorkspace
                function onHasFullscreenChanged() {
                    if (!Preferences.bar.autoHide) {
                        shouldShow = !Hyprland.focusedWorkspace.hasFullscreen;
                    }
                }
            }

            Item {
                id: barItem
                anchors.fill: parent

                transform: Translate {
                    id: slideTransform

                    property real targetX: {
                        if (!shouldShow) {
                            const pos = Preferences.bar.position.toLowerCase();
                            if (pos === 'left')
                                return -barItem.width;
                            if (pos === 'right')
                                return barItem.width;
                        }
                        return 0;
                    }

                    property real targetY: {
                        if (!shouldShow) {
                            const pos = Preferences.bar.position.toLowerCase();
                            if (pos === 'top')
                                return -barItem.height;
                            if (pos === 'bottom')
                                return barItem.height;
                        }
                        return 0;
                    }

                    x: targetX
                    y: targetY

                    Behavior on x {
                        NumberAnimation {
                            duration: Appearance.animation.fast
                            easing.type: Appearance.animation.easing
                            onRunningChanged: {
                                window.isAnimating = running;
                            }
                        }
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: Appearance.animation.fast
                            easing.type: Appearance.animation.easing
                            onRunningChanged: {
                                window.isAnimating = running;
                            }
                        }
                    }
                }

                HoverHandler {
                    id: barHover
                }

                Loader {
                    id: barLoader
                    anchors.fill: parent
                    sourceComponent: Preferences.verticalBar() ? barVertical : barHorizontal
                }
            }

            Component {
                id: barHorizontal
                BarContainer {}
            }
            Component {
                id: barVertical
                VBarContainer {}
            }

            Rectangle {
                id: hoverZone
                color: "transparent"

                Component.onCompleted: positionHoverZone()

                Connections {
                    target: Preferences.bar
                    function onPositionChanged() {
                        hoverZone.positionHoverZone();
                    }
                }

                function positionHoverZone() {
                    anchors.top = undefined;
                    anchors.bottom = undefined;
                    anchors.left = undefined;
                    anchors.right = undefined;

                    const pos = Preferences.bar.position.toLowerCase();

                    if (pos === 'top') {
                        anchors.top = parent.top;
                        anchors.left = parent.left;
                        anchors.right = parent.right;
                        height = 2;
                    } else if (pos === 'bottom') {
                        anchors.bottom = parent.bottom;
                        anchors.left = parent.left;
                        anchors.right = parent.right;
                        height = 2;
                    } else if (pos === 'left') {
                        anchors.left = parent.left;
                        anchors.top = parent.top;
                        anchors.bottom = parent.bottom;
                        width = 2;
                    } else if (pos === 'right') {
                        anchors.right = parent.right;
                        anchors.top = parent.top;
                        anchors.bottom = parent.bottom;
                        width = 2;
                    }
                }

                HoverHandler {
                    id: hover
                }
            }

            Connections {
                target: hover
                function onHoveredChanged() {
                    updateHoverState();
                }
            }

            Connections {
                target: barHover
                function onHoveredChanged() {
                    updateHoverState();
                }
            }

            Timer {
                id: hideDelay
                interval: 150
                repeat: false
                onTriggered: {
                    if (!hover.hovered && !barHover.hovered) {
                        shouldShow = false;
                        Globals.isBarHovered = false;
                    }
                }
            }
        }
    }
}
