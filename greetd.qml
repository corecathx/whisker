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

    property string curState: "userSelection" // userSelection, enterPassword
    property string curUsername: ""
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

        Image {
            id: bgImage
            anchors.fill: parent
            sourceSize: Qt.size(bgWindow.width, bgWindow.height)
            source: root.curUsername !== "" ? "file:///var/lib/whisker/wallpapers/" + root.curUsername : ""
            fillMode: Image.PreserveAspectCrop
            smooth: true
            cache: true
            opacity: root.curState === "enterPassword" ? 1 : 0
            scale: root.curState === "enterPassword" ? 1.02 : 1
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1
                blurMax: 32
                brightness: -0.1
                contrast: 0.1
                layer.enabled: true
                layer.effect: MultiEffect {
                    autoPaddingEnabled: false
                    blurEnabled: true
                    blur: 1
                    blurMax: 32
                }
            }
            Behavior on opacity { NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing } }
            Behavior on scale { NumberAnimation { duration: Appearance.animation.slow; easing.type: Appearance.animation.easing } }
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
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 20
        }
        Item {
            width: things.width + 10
            height: things.height + 10
            anchors {
                right: parent.right
                top: parent.top
                margins: 20
            }
            Rectangle {
                color: Appearance.colors.m3surface
                anchors.fill: parent
                radius: Appearance.rounding.extraLarge
            }
            RowLayout {
                id: things
                anchors.centerIn: parent
                spacing: 5

                Item {
                    width: things2.width + 10
                    height: things2.height + 3
                    Rectangle {
                        color: Appearance.colors.m3surface_container
                        anchors.fill: parent
                        radius: Appearance.rounding.extraLarge
                    }
                    RowLayout {
                        id: things2
                        anchors.centerIn: parent
                        spacing: 10

                        AudioTray {}
                        NetworkTray {}
                        BluetoothTray {}
                    }
                }
                Battery {}
            }
        }

        Item {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 40
            width: 440
            height: loginBox.height
            clip: true

            Rectangle {
                id: loginBox
                anchors.centerIn: parent
                width: parent.width
                height: content.height + 60
                radius: Appearance.rounding.extraLarge
                color: Appearance.colors.m3surface_container

                Behavior on width { NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing } }
                Behavior on height { NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing } }

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
                    GridLayout {
                        columns: 3
                        rowSpacing: 20
                        columnSpacing: 20
                        visible: root.curState === "userSelection"
                        opacity: visible ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: Appearance.animation.slow; easing.type: Appearance.animation.easing } }
                        Layout.alignment: Qt.AlignHCenter
                        Repeater {
                            model: root.detectedUsers
                            delegate: UserEntry {
                                required property string modelData
                                username: modelData
                                onClicked: {
                                    root.prepareLogin(modelData);
                                }
                            }
                        }
                    }
                    Item {
                        id: loginPart
                        visible: root.curState === "enterPassword"
                        opacity: visible ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: Appearance.animation.slow; easing.type: Appearance.animation.easing } }
                        implicitHeight: loginLayout.height
                        implicitWidth: parent.width
                        Layout.alignment: Qt.AlignHCenter

                        StyledButton {
                            icon: "chevron_left"
                            secondary: true
                            anchors {
                                left: parent.left
                                top: parent.top
                            }
                            onClicked: root.curState = 'userSelection'
                        }
                        ColumnLayout {
                            id: loginLayout
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 12

                            ProfileIcon {
                                implicitWidth: 140
                                implicitHeight: 140
                                Layout.alignment: Qt.AlignHCenter
                                username: root.curUsername
                                color: Appearance.colors.m3surface_container_high
                            }
                            StyledText {
                                text: root.curUsername
                                font.pixelSize: 32
                                font.family: "Outfit SemiBold"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            StyledTextField {
                                id: passwordInput
                                placeholder: "Password"
                                icon: "lock"
                                echoMode: TextField.Password
                                fieldPadding: 15
                                // filled: false
                                Layout.fillWidth: true

                                Keys.onReturnPressed: submitLogin()
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 12

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

                                onClicked: submitLogin()
                                enabled: statusText.text === "" || statusText.text.includes("Failed")
                            }
                        }
                    }
                }
            }
        }

        Item {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20
            width: controls.width + 10
            height: controls.height + 10
            Rectangle {
                anchors.fill: parent
                color: Appearance.colors.m3surface
                radius: Appearance.rounding.extraLarge
            }
            RowLayout {
                id: controls
                anchors.centerIn: parent
                spacing: 5
                StyledButton {
                    icon: "power_settings_new"
                    secondary: true
                    implicitHeight: 32
                    onClicked: {
                        Quickshell.execDetached({ command: ["systemctl", "poweroff" ]})
                    }
                }

                StyledButton {
                    icon: "restart_alt"
                    implicitHeight: 32
                    secondary: true
                    onClicked: {
                        Quickshell.execDetached({ command: ["systemctl", "reboot" ]})
                    }
                }
            }
        }
    }

    function prepareLogin(username) {
        root.curUsername = username
        root.curState = "enterPassword"
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

    component UserEntry: Item {
        id: entry
        required property string username;
        signal clicked();
        Layout.minimumWidth: entryLayout.height + 20
        width: entryLayout.width + 20
        height: entryLayout.height + 20
        Layout.alignment: Qt.AlignHCenter
        Rectangle {
            anchors.fill: parent
            color: mouse.containsMouse ? Appearance.colors.m3surface_container_highest : Appearance.colors.m3surface_container_high
            Behavior on color { ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
            radius: Appearance.rounding.large
        }
        ColumnLayout {
            id: entryLayout
            anchors.centerIn: parent
            ProfileIcon {
                implicitWidth: 60
                implicitHeight: 60
                Layout.alignment: Qt.AlignHCenter
                username: entry.username
            }
            StyledText {
                text: entry.username
                font.pixelSize: 18

                font.family: "Outfit SemiBold"
                Layout.alignment: Qt.AlignHCenter
            }
        }
        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: entry.clicked()
        }
    }
}
