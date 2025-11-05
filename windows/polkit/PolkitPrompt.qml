import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import Quickshell
import Quickshell.Wayland

import qs.modules
import qs.services
import qs.components

Scope {
    id: root
    property bool active: false
    property var window: null

    Connections {
        target: Polkit
        function onIsActiveChanged() {
            if (Polkit.isActive) {
                root.active = true
            } else if (root.active && window) {
                window.closeWithAnimation()
            }
        }
    }

    LazyLoader {
        active: root.active
        component: PanelWindow {
            id: window
            property bool isClosing: false

            Component.onCompleted: root.window = window
            Component.onDestruction: root.window = null

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "whisker:polkitprompt"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "transparent"

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
                        target: promptContainer
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
                        target: promptContainer
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
                        target: promptContainer
                        property: "opacity"
                        to: 0
                        duration: Appearance.animation.medium
                        easing.type: Appearance.animation.easing
                    }
                    NumberAnimation {
                        target: promptContainer
                        property: "scale"
                        to: 0.9
                        duration: Appearance.animation.medium
                        easing.type: Appearance.animation.easing
                    }
                    onFinished: root.active = false
                }

                Item {
                    id: promptContainer
                    property bool showPassword: false
                    property bool authenticating: false

                    anchors.centerIn: parent
                    width: promptBg.width
                    height: promptBg.height
                    opacity: 0
                    scale: 0.9

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowOpacity: 1
                        shadowColor: Appearance.colors.m3shadow
                        shadowBlur: 1
                        shadowScale: 1
                    }

                    Rectangle {
                        id: promptBg
                        width: promptLayout.width + 40
                        height: promptLayout.height + 40
                        color: Appearance.colors.m3surface
                        radius: 20

                        Behavior on height {
                            NumberAnimation {
                                duration: Appearance.animation.fast
                                easing.type: Appearance.animation.easing
                            }
                        }
                    }

                    ColumnLayout {
                        id: promptLayout
                        spacing: 10
                        anchors {
                            left: promptBg.left
                            leftMargin: 20
                            top: promptBg.top
                            topMargin: 20
                        }

                        ColumnLayout {
                            spacing: 5
                            MaterialIcon {
                                icon: "security"
                                color: Appearance.colors.m3primary
                                font.pixelSize: 30
                                Layout.alignment: Qt.AlignHCenter
                            }
                            StyledText {
                                text: "Authentication required"
                                font.family: "Outfit SemiBold"
                                font.pixelSize: 20
                                Layout.alignment: Qt.AlignHCenter
                            }
                            StyledText {
                                text: Polkit.flow.message
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        RowLayout {
                            spacing: 5
                            StyledTextField {
                                id: textfield
                                Layout.fillWidth: true
                                leftPadding: undefined
                                padding: 10
                                radius: 10
                                topRightRadius: 5
                                bottomRightRadius: 5
                                enabled: !promptContainer.authenticating
                                placeholder: Polkit.flow.inputPrompt.substring(0, Polkit.flow.inputPrompt.length - 2)
                                echoMode: promptContainer.showPassword ? TextInput.Normal : TextInput.Password
                                inputMethodHints: Qt.ImhSensitiveData
                                focus: true
                                Keys.onReturnPressed: okButton.clicked()
                            }
                            StyledButton {
                                Layout.fillHeight: true
                                width: height
                                radius: 10
                                topLeftRadius: 5
                                bottomLeftRadius: 5
                                enabled: !promptContainer.authenticating
                                checkable: true
                                checked: promptContainer.showPassword
                                icon: promptContainer.showPassword ? 'visibility' : 'visibility_off'
                                onToggled: promptContainer.showPassword = !promptContainer.showPassword
                            }
                        }

                        LoadingIcon {
                            visible: promptContainer.authenticating
                            Layout.alignment: Qt.AlignHCenter
                        }

                        RowLayout {
                            visible: Polkit.flow.failed && !Polkit.flow.isSuccessful
                            MaterialIcon {
                                icon: "warning"
                                color: Appearance.colors.m3error
                                font.pixelSize: 16
                            }
                            StyledText {
                                text: "Failed to authenticate, incorrect password."
                                color: Appearance.colors.m3error
                                font.pixelSize: 12
                            }
                        }

                        RowLayout {
                            Item { Layout.fillWidth: true }
                            StyledButton {
                                radius: 10
                                topRightRadius: 5
                                bottomRightRadius: 5
                                secondary: true
                                text: "Cancel"
                                enabled: !promptContainer.authenticating
                                onClicked: Polkit.flow.cancelAuthenticationRequest()
                            }
                            StyledButton {
                                id: okButton
                                radius: 10
                                topLeftRadius: 5
                                bottomLeftRadius: 5
                                text: promptContainer.authenticating ? "Authenticating..." : "OK"
                                enabled: !promptContainer.authenticating
                                onClicked: {
                                    promptContainer.authenticating = true
                                    Polkit.flow.submit(textfield.text)
                                }
                            }
                        }
                    }

                    Connections {
                        target: Polkit.flow
                        function onIsCompletedChanged() {
                            if (Polkit.flow.isCompleted) {
                                promptContainer.authenticating = false
                            }
                        }
                        function onFailedChanged() {
                            if (Polkit.flow.failed) {
                                promptContainer.authenticating = false
                            }
                        }
                        function onIsCancelledChanged() {
                            if (Polkit.flow.isCancelled) {
                                promptContainer.authenticating = false
                            }
                        }
                    }
                }
            }
        }
    }
}
