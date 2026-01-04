import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Greetd
import qs.components
import qs.modules
import qs.services
import qs.modules.bar

ShellRoot {
    id: root

    property var detectedUsers: []
    property var detectedDEs: []
    property var detectedDECommands: []
    property bool showUserInput: false
    property int selectedDE: 0

    Process {
        id: getUsersProcess
        running: true
        command: ["bash", "-c", "getent passwd | grep -E ':[0-9]{4}:' | cut -d: -f1"]
        stdout: StdioCollector {
            onStreamFinished: {
                var userList = text.trim().split('\n').filter(u => u.length > 0)
                root.detectedUsers = userList
            }
        }
    }

    Process {
        id: getDEsProcess
        running: true
        command: ["bash", "-c", "find /usr/share/wayland-sessions/ -name '*.desktop' 2>/dev/null | while read f; do name=$(grep '^Name=' \"$f\" | cut -d= -f2); exec=$(grep '^Exec=' \"$f\" | cut -d= -f2); echo \"$name|||$exec\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split('\n').filter(l => l.length > 0)
                var names = []
                var commands = []

                if (lines.length === 0) {
                    names = ["Default Session"]
                    commands = ["bash"]
                } else {
                    for (var i = 0; i < lines.length; i++) {
                        var parts = lines[i].split('|||')
                        if (parts.length === 2) {
                            names.push(parts[0])
                            commands.push(parts[1])
                        }
                    }
                }

                root.detectedDEs = names
                root.detectedDECommands = commands
            }
        }
    }

    PanelWindow {
        id: bgWindow
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }
        color: Appearance.colors.m3surface_dim
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Appearance.colors.m3surface_dim }
                GradientStop { position: 1.0; color: Qt.darker(Appearance.colors.m3surface_dim, 1.1) }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 20
            width: statusRow.width + 20
            height: statusRow.height + 10
            radius: 20
            color: Appearance.colors.m3error
            visible: !Greetd.available
            RowLayout {
                id: statusRow
                anchors.centerIn: parent
                spacing: 5

                MaterialIcon {
                    icon: 'error'
                    color: Appearance.colors.m3on_error
                }

                StyledText {
                    color: Appearance.colors.m3on_error
                    text: "Greetd is not running!"
                    font.pixelSize: 10
                }
            }
        }

        StyledText {
            id: timeText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 100
            color: Appearance.colors.m3on_surface
            text: Qt.formatDateTime(Time.date, "HH:mm")
            font.pixelSize: 96
            font.family: "Outfit ExtraBold"
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: timeText.bottom
            color: Appearance.colors.m3on_surface_variant
            text: Qt.formatDateTime(Time.date, "dddd, dd/MM")
            font.bold: true
            font.pixelSize: 32
        }
    }

    PanelWindow {
        id: loginWindow
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        StyledButton {
            text: "exit"
            onClicked: Qt.quit()
            visible: !Greetd.available
        }
        Item {
            width: things.width
            height: things.height
            anchors {
                right: parent.right
                top: parent.top
                margins: 20
            }
            RowLayout {
                id: things
                spacing: 10

                AudioTray {}
                NetworkTray {}
                BluetoothTray {}
                Battery {}
            }
        }

        Item {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 40
            width: 440
            height: loginBox.height

            Rectangle {
                id: loginBox
                anchors.centerIn: parent
                width: parent.width
                height: content.height + 60
                radius: 20
                color: Appearance.colors.m3surface_container_low

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowOpacity: 0.3
                    shadowColor: Appearance.colors.m3shadow
                    shadowBlur: 1
                    shadowScale: 1
                }

                ColumnLayout {
                    id: content
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                    anchors.margins: 30
                    spacing: 20
                    ColumnLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                        }
                        spacing: 20
                    }
                    ColumnLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                        }
                        spacing: 20

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            visible: !root.showUserInput

                            StyledText {
                                text: "User"
                                font.pixelSize: 14
                                font.family: "Outfit Medium"
                                color: Appearance.colors.m3on_surface_variant
                            }

                            StyledDropDown {
                                Layout.fillWidth: true
                                model: root.detectedUsers

                                onSelectedIndexChanged: (index) => {
                                    usernameInput.text = root.detectedUsers[index]
                                    root.showUserInput = false
                                    passwordInput.forceActiveFocus()
                                }
                            }

                            StyledButton {
                                Layout.fillWidth: true
                                text: "Other user"
                                secondary: true
                                onClicked: {
                                    root.showUserInput = true
                                    usernameInput.forceActiveFocus()
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            visible: root.showUserInput

                            StyledText {
                                text: "Username"
                                font.pixelSize: 14
                                font.family: "Outfit Medium"
                                color: Appearance.colors.m3on_surface_variant
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                StyledButton {
                                    icon: "arrow_back"
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    secondary: true
                                    onClicked: root.showUserInput = false
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    StyledTextField {
                                        id: usernameInput
                                        Layout.fillWidth: true
                                        placeholder: "Enter username"
                                        fieldPadding: 15
                                        icon: "person"
                                        filled: false
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            visible: usernameInput.text.length > 0

                            StyledText {
                                text: "Password"
                                font.pixelSize: 14
                                font.family: "Outfit Medium"
                                color: Appearance.colors.m3on_surface_variant
                            }

                            StyledTextField {
                                id: passwordInput
                                Layout.fillWidth: true
                                placeholder: "Enter password"
                                icon: "lock"
                                echoMode: TextField.Password
                                fieldPadding: 15
                                filled: false

                                Keys.onReturnPressed: submitLogin()
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            visible: usernameInput.text.length > 0

                            StyledText {
                                text: "Session"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: Appearance.colors.m3on_surface_variant
                            }

                            StyledDropDown {
                                Layout.fillWidth: true
                                model: root.detectedDEs
                                currentIndex: root.selectedDE

                                onSelectedIndexChanged: (index) => {
                                    root.selectedDE = index
                                }
                            }
                        }

                        StyledText {
                            id: statusText
                            Layout.fillWidth: true
                            font.pixelSize: 13
                            color: statusText.text.includes("Failed") || statusText.text.includes("Error")
                                ? Appearance.colors.m3error
                                : Appearance.colors.m3primary
                            wrapMode: Text.WordWrap
                            visible: text !== ""
                            horizontalAlignment: Text.AlignHCenter
                        }

                        StyledButton {
                            id: loginButton
                            Layout.fillWidth: true
                            text: statusText.text === "" ? "Sign in" : statusText.text
                            icon: statusText.text === "" ? "login" : ""
                            visible: usernameInput.text.length > 0

                            onClicked: submitLogin()
                            enabled: statusText.text === "" || statusText.text.includes("Failed")
                        }
                    }
                }
            }
        }

        RowLayout {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20
            spacing: 12

            StyledButton {
                icon: "power_settings_new"
                secondary: true
                onClicked: {
                    Quickshell.execDetached({ command: ["systemctl", "poweroff" ]})
                }
            }

            StyledButton {
                icon: "restart_alt"
                secondary: true
                onClicked: {
                    Quickshell.execDetached({ command: ["systemctl", "reboot" ]})
                }
            }
        }
    }

    function submitLogin() {
        if (usernameInput.text.length > 0 && passwordInput.text.length > 0) {
            loginButton.enabled = false
            statusText.text = "Authenticating..."
            Greetd.createSession(usernameInput.text)
        }
    }

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            statusText.text = message

            if (responseRequired) {
                passwordInput.forceActiveFocus()
                if (passwordInput.text.length > 0) {
                    Greetd.respond(passwordInput.text)
                }
            }
        }

        function onAuthFailure(message) {
            statusText.text = "Failed: " + message
            passwordInput.text = ""
            loginButton.enabled = true
        }

        function onReadyToLaunch() {
            statusText.text = "Launching..."

            var command = ["bash"]
            if (root.selectedDE < root.detectedDECommands.length)
                command = [root.detectedDECommands[root.selectedDE]]

            Log.info("greetd.qml", "Launching command: " + command)
            Greetd.launch(command)
        }

        function onError(error) {
            statusText.text = "Error: " + error
            loginButton.enabled = true
        }
    }
}
