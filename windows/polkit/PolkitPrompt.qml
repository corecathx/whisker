import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import Quickshell
import Quickshell.Wayland

import qs.modules
import qs.windows
import qs.services
import qs.components
import qs.components.effects

Scope {
    id: root
    property bool active: false
    property var window: null

    Connections {
        target: Polkit
        function onIsActiveChanged() {
            if (Polkit.isActive) {
                root.active = true;
            } else if (root.active && window) {
                window.closeWithAnimation();
            }
        }
    }

    LazyLoader {
        active: root.active
        component: FullscreenPrompt {
            id: window

            Component.onCompleted: root.window = window
            Component.onDestruction: root.window = null

            onFadeOutFinished: root.active = false

            Item {
                id: promptContainer
                property bool showPassword: false
                property bool authenticating: false

                anchors.centerIn: parent
                width: promptBg.width
                height: promptBg.height

                BaseShadow {}

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
                            filled: false
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
                        Item {
                            Layout.fillWidth: true
                        }
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
                                promptContainer.authenticating = true;
                                Polkit.flow.submit(textfield.text);
                            }
                        }
                    }
                }

                Connections {
                    target: Polkit.flow
                    function onIsCompletedChanged() {
                        if (Polkit.flow.isCompleted) {
                            promptContainer.authenticating = false;
                        }
                    }
                    function onFailedChanged() {
                        if (Polkit.flow.failed) {
                            promptContainer.authenticating = false;
                        }
                    }
                    function onIsCancelledChanged() {
                        if (Polkit.flow.isCancelled) {
                            promptContainer.authenticating = false;
                        }
                    }
                }
            }
        }
    }
}
