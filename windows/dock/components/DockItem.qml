import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland

import qs.services
import qs.modules
import qs.components

Item {
    id: item
    required property string modelData

    property int dockIndex: -1
    property bool isRunning: Hyprland.classIsRunning(modelData)
    property bool previewOnTooltip: true

    property bool tooltipVisible: false
    property int tooltipDelay: 400

    Layout.preferredWidth: mouseArea.containsMouse && !mouseArea.pressed ? 80 : 50

    Behavior on Layout.preferredWidth {
        NumberAnimation {
            duration: Appearance.animation.fastest
            easing.type: Appearance.animation.easingExpressive
        }
    }

    Layout.preferredHeight: 50
    StyledRectangle {
        anchors.fill: parent
        color: {
            if (mouseArea.containsMouse && !mouseArea.pressed) 
                return Appearance.colors.m3surface_container_high

            return Appearance.colors.m3surface_container
        }
        Behavior on color {
            ColorAnimation {
                duration: Appearance.animation.fastest
            }
        }
        radius: Appearance.rounding.medium
    }
    Item {
        id: icon
        anchors {
            top: parent.top
            bottom: parent.bottom
            margins: 6
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.height

        scale: mouseArea.pressed ? 0.8 : 1
        Behavior on scale {
            NumberAnimation {
                duration: Appearance.animation.fastest
                easing.type: Appearance.animation.easingExpressive
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            colorization: {
                if (!item.isRunning && mouseArea.containsMouse)
                    return 0.0
                if (!item.isRunning) 
                    return 1.0

                return 0.0
            }
            Behavior on colorization {
                NumberAnimation {
                    duration: Appearance.animation.fastest
                }
            }
            colorizationColor: Appearance.colors.m3on_surface
        }

        IconImage {
            id: iconImage
            anchors.fill: parent
            property int retryCount: 0

            source: {
                console.log("REFRESH")
                retryCount
                return Utils.getAppIcon(modelData, "")
            }

            Timer {
                interval: 1000
                repeat: true
                running: iconImage.source == "" && iconImage.retryCount < 5
                onTriggered: iconImage.retryCount++
            }
        }

        MaterialIcon {
            id: iconFallback
            visible: iconImage.source == ""
            icon: {
                return "terminal";
            }
            anchors.centerIn: parent
            font.pixelSize: 40
            color: Appearance.colors.m3on_surface
            Layout.alignment: Qt.AlignVCenter
        }
    }

    StyledRectangle {
        width: 5
        height: 5
        radius: height
        color: Appearance.colors.m3primary
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
        opacity: item.isRunning ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.animation.fast
            }
        }
    }

    Timer {
        id: tooltipTimer
        interval: item.tooltipDelay
        onTriggered: item.tooltipVisible = true
    }

    Item {
        id: tooltip
        opacity: item.tooltipVisible ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.animation.fastest
            }
        }
        width: contentLayout.implicitWidth + 20
        height: contentLayout.implicitHeight + 20
        x: (parent.width - width) / 2
        y: -height - 8
        z: 100

        StyledRectangle {
            anchors.fill: parent
            color: Appearance.colors.m3surface
            radius: Appearance.rounding.medium
        }


        ColumnLayout {
            id: contentLayout
            anchors.centerIn: parent
            StyledText {
                id: tooltipText 
                property int retryCount: 0
                text: {
                    retryCount
                    return Utils.getDesktopEntry(modelData)?.name ?? modelData
                }
                color: Appearance.colors.m3on_surface//
                font.pixelSize: 14
                Timer {
                    interval: 1000
                    repeat: true
                    running: tooltipText.text == modelData && tooltipText.retryCount < 5
                    onTriggered: tooltipText.retryCount++
                }
            }
            ClippingRectangle {
                visible: item.isRunning && item.previewOnTooltip

                implicitWidth: 400
                implicitHeight: previewContainer.implicitHeight
                radius: 10
                color: Appearance.colors.m3surface_container

                Item {
                    id: previewContainer
                    anchors.fill: parent
                    implicitWidth: 400
                    implicitHeight: {
                        if (preview.sourceSize.width > 0 && preview.sourceSize.height > 0) {
                            let calculatedHeight = 400 * preview.sourceSize.height / preview.sourceSize.width;
                            return Math.min(calculatedHeight, 400);
                        }
                        return 400;
                    }

                    ScreencopyView {
                        id: preview
                        anchors.fill: parent
                        anchors.margins: 2
                        captureSource: {
                            let handle = Hyprland.getToplevelFromClass(modelData)?.wayland
                            if (handle)
                                return handle
                            return null
                        }
                        live: item.isRunning && item.previewOnTooltip && tooltip.opacity > 0
                    }
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Log.info('windows/dock/Dock.qml', 'clicked on ' + item.modelData + ' dock item');
            if (item.isRunning)
                Hyprland.focusToClass(item.modelData)
            else {
                let entry = Utils.getDesktopEntry(item.modelData)
                if (entry)
                    entry.execute();
            }
        }

        onEntered: {
            item.tooltipVisible = false
            tooltipTimer.start()
        }

        onExited: {
            tooltipTimer.stop()
            item.tooltipVisible = false
        }
    }
}