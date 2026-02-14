import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import Quickshell
import Quickshell.Wayland

import qs.modules
import qs.services
import qs.components

PanelWindow {
    id: window
    property bool isClosing: false
    default property alias content: contentContainer.data
    signal fadeOutFinished()

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: Appearance.colors.m3surface
    WlrLayershell.namespace: "whisker:prompt"

    function closeWithAnimation() {
        if (isClosing) return
        isClosing = true
        fadeOutAnim.start()
    }

    Item {
        anchors.fill: parent

        ScreencopyView {
            id: screencopy
            visible: hasContent
            captureSource: window.screen
            anchors.fill: parent
            opacity: 0
            scale: 1
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1
                blurMax: 32
                brightness: -0.05
                layer.enabled: true
                layer.effect: MultiEffect {
                    autoPaddingEnabled: false
                    blurEnabled: true
                    blur: 1
                    blurMax: 32
                }
            }
        }

        NumberAnimation {
            id: fadeInAnim
            target: screencopy
            property: "opacity"
            from: 0
            to: 1
            duration: Appearance.animation.medium
            easing.type: Appearance.animation.easing
            running: screencopy.visible && !window.isClosing
        }

        ParallelAnimation {
            id: scaleInAnim
            running: screencopy.visible && !window.isClosing
            NumberAnimation {
                target: contentContainer
                property: "scale"
                from: 0.9
                to: 1
                duration: Appearance.animation.medium
                easing.type: Appearance.animation.easing
            }
            ColorAnimation {
                target: window
                property: "color"
                from: "transparent"
                to: Appearance.colors.m3surface
                duration: Appearance.animation.medium
                easing.type: Appearance.animation.easing
            }
            NumberAnimation {
                target: contentContainer
                property: "opacity"
                from: 0
                to: 1
                duration: Appearance.animation.medium
                easing.type: Appearance.animation.easing
            }
        }

        ParallelAnimation {
            id: fadeOutAnim
            NumberAnimation {
                target: screencopy
                property: "opacity"
                to: 0
                duration: Appearance.animation.medium
                easing.type: Appearance.animation.easing
            }
            ColorAnimation {
                target: window
                property: "color"
                to: "transparent"
                duration: Appearance.animation.medium
                easing.type: Appearance.animation.easing
            }
            NumberAnimation {
                target: contentContainer
                property: "opacity"
                to: 0
                duration: Appearance.animation.medium
                easing.type: Appearance.animation.easing
            }
            NumberAnimation {
                target: contentContainer
                property: "scale"
                to: 0.9
                duration: Appearance.animation.medium
                easing.type: Appearance.animation.easing
            }
            onFinished: {
                window.visible = false
                window.fadeOutFinished()
            }
        }

        Item {
            id: contentContainer
            anchors.fill: parent
            opacity: 0
            scale: 0.9
        }
    }
}
