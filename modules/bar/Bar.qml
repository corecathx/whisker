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

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            property var modelData
            screen: modelData
            property bool shouldShow: !Preferences.autoHideBar
            property bool isAnimating: false

            exclusionMode: {
                if (!Preferences.autoHideBar)
                    return ExclusionMode.Auto
                return ExclusionMode.Ignore
            }

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: 'whisker:bar'
            color: "transparent"

            mask: Region {
                id: maskRegion

                x: {
                    if (!Preferences.autoHideBar) return 0;
                    return Globals.isBarHovered ? 0 : hoverZone.x
                }
                y: {
                    if (!Preferences.autoHideBar) return 0;
                    Globals.isBarHovered ? 0 : hoverZone.y
                }
                width:{
                    if (!Preferences.autoHideBar) return window.width;
                    return Globals.isBarHovered ? window.width : hoverZone.width
                }

                height: {
                    if (!Preferences.autoHideBar) return window.height;
                    return Globals.isBarHovered ? window.height : hoverZone.height
                }
            }

            anchors {
                top: Preferences.barPosition === 'top' || Preferences.verticalBar()
                bottom: Preferences.barPosition === 'bottom' || Preferences.verticalBar()
                left: Preferences.barPosition === 'left' || Preferences.horizontalBar()
                right: Preferences.barPosition === 'right' || Preferences.horizontalBar()
            }

            implicitHeight: barLoader.item ? barLoader.item.implicitHeight : 0
            implicitWidth: barLoader.item ? barLoader.item.implicitWidth : 0

            function updateHoverState() {
                if (!Preferences.autoHideBar) {
                    Globals.isBarHovered = false
                    return
                }

                const hovering = hover.hovered || barHover.hovered

                if (hovering) {
                    hideDelay.stop()
                    shouldShow = true
                    Globals.isBarHovered = true
                } else {
                    hideDelay.restart()
                }
            }
            Connections {
                target: Preferences
                function onAutoHideBarChanged() {
                    shouldShow = !Preferences.autoHideBar
                }
            }

            Item {
                id: barItem
                anchors.fill: parent
                visible: shouldShow || isAnimating

                transform: Translate {
                    id: slideTransform

                    property real targetX: {
                        if (!Preferences.autoHideBar) return 0
                        if (!shouldShow) {
                            const pos = Preferences.barPosition.toLowerCase()
                            if (pos === 'left') return -barItem.width
                            if (pos === 'right') return barItem.width
                        }
                        return 0
                    }

                    property real targetY: {
                        if (!Preferences.autoHideBar) return 0
                        if (!shouldShow) {
                            const pos = Preferences.barPosition.toLowerCase()
                            if (pos === 'top') return -barItem.height
                            if (pos === 'bottom') return barItem.height
                        }
                        return 0
                    }

                    x: targetX
                    y: targetY

                    Behavior on x {
                        NumberAnimation {
                            duration: Appearance.animation.fast
                            easing.type: Appearance.animation.easing
                            onRunningChanged: {
                                if (running) window.isAnimating = true
                                else window.isAnimating = false
                            }
                        }
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: Appearance.animation.fast
                            easing.type: Appearance.animation.easing
                            onRunningChanged: {
                                if (running) window.isAnimating = true
                                else window.isAnimating = false
                            }
                        }
                    }
                }

                HoverHandler { id: barHover }

                Loader {
                    id: barLoader
                    anchors.fill: parent
                    sourceComponent: Preferences.verticalBar() ? barVertical : barHorizontal
                }
            }

            Component { id: barHorizontal; BarContainer {} }
            Component { id: barVertical; VBarContainer {} }

            Rectangle {
                id: hoverZone
                color: "transparent"

                Component.onCompleted: positionHoverZone()

                Connections {
                    target: Preferences
                    function onBarPositionChanged() { hoverZone.positionHoverZone() }
                }

                function positionHoverZone() {
                    anchors.top = undefined
                    anchors.bottom = undefined
                    anchors.left = undefined
                    anchors.right = undefined

                    const pos = Preferences.barPosition.toLowerCase()

                    if (pos === 'top') {
                        anchors.top = parent.top
                        anchors.left = parent.left
                        anchors.right = parent.right
                        height = 2
                    } else if (pos === 'bottom') {
                        anchors.bottom = parent.bottom
                        anchors.left = parent.left
                        anchors.right = parent.right
                        height = 2
                    } else if (pos === 'left') {
                        anchors.left = parent.left
                        anchors.top = parent.top
                        anchors.bottom = parent.bottom
                        width = 2
                    } else if (pos === 'right') {
                        anchors.right = parent.right
                        anchors.top = parent.top
                        anchors.bottom = parent.bottom
                        width = 2
                    }
                }

                HoverHandler { id: hover }
            }

            Connections {
                target: hover
                function onHoveredChanged() { updateHoverState() }
            }

            Connections {
                target: barHover
                function onHoveredChanged() { updateHoverState() }
            }

            Timer {
                id: hideDelay
                interval: 150
                repeat: false
                onTriggered: {
                    if (!hover.hovered && !barHover.hovered) {
                        shouldShow = false
                        Globals.isBarHovered = false
                    }
                }
            }
        }
    }
}
