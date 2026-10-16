import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Greetd

import qs.modules
import qs.components

Item {
    id: root

    property int state: 0 // 0 = user selection; 1 = login screen
    function changeState(newState: int) {
        let validState = true
        let oldState = state

        switch (newState) {
            case 0:
                if (oldState == 1) {
                    if (root.authenticating || root.awaitingResponse)
                        Greetd.cancelSession()

                    root.authenticating = false
                    root.awaitingResponse = false
                    passwordInput.text = ""
                    passwordInput.focus = false
                    statusText.text = ""
                    root.focus = true
                    switchToList.restart()
                }
                break;
            case 1:
                if (oldState == 0) {
                    passwordInput.focus = true
                    root.focus = false
                    switchToLogin.restart();
                }
                break
            default:
                validState = false
                _logWarn("unhandled state: " + state);
        }
        
        if (validState) 
            state = newState
    }

    // property var users: ['corecat', 'bytewolf', 'keandawg', 'chiproot']
    property var users: []
    property int selectedUser: 0
    function changeSelectedUser(add: int, force = false) {
        if (force) 
            selectedUser = add
        else
            selectedUser += add

        if (selectedUser > users.length - 1)
            selectedUser = 0
        else if (selectedUser < 0)
            selectedUser = users.length - 1
    }

    property var sessions: []
    property int selectedSession: 0

    property bool authenticating: false
    property bool awaitingResponse: false

    property real defaultUserContainerMargin: 100
    property int loginTransitionDuration: Appearance.animation.slow

    property bool disableUserSelectionUI: false

    focus: true

    signal enterPressed()
    signal attemptLogin(var username, var password)

    Keys.onPressed: event => {
        switch (state) {
            case 0:
                if (event.key === Qt.Key_Up) {
                    root.changeSelectedUser(-1)
                    event.accepted = true
                } else if (event.key === Qt.Key_Down) {
                    root.changeSelectedUser(1)
                    event.accepted = true
                } else if (event.key === Qt.Key_Left) {
                    root.selectedSession = Math.max(0, root.selectedSession - 1)
                    event.accepted = true
                } else if (event.key === Qt.Key_Right) {
                    root.selectedSession = Math.max(0, Math.min(root.sessions.length - 1, root.selectedSession + 1))
                    event.accepted = true
                } else if (event.key === Qt.Key_Return) {
                    root.enterPressed()
                    event.accepted = true
                }
                break;
            case 1:

                break
            default:
                _logWarn("unhandled state on key press: " + state);
        }
    }

    Item {
        id: animationContainer
        ParallelAnimation {
            id: switchToLogin
            NumberAnimation {
                target: userContainer
                property: 'anchors.margins'
                // from: root.defaultUserContainerMargin
                to: (userContainer.width + 20) * -1
                duration: root.loginTransitionDuration
                easing.type: Appearance.animation.easing
            }
            NumberAnimation {
                target: loginContainer
                property: 'scale'
                // from: 0.9
                to: 1
                duration: root.loginTransitionDuration
                easing.type: Appearance.animation.easing
            }
            NumberAnimation {
                target: loginContainer
                property: 'opacity'
                // from: 0
                to: 1
                duration: root.loginTransitionDuration
                easing.type: Appearance.animation.easing
            }
        }
        ParallelAnimation {
            id: switchToList
            NumberAnimation {
                target: userContainer
                property: 'anchors.margins'
                // from: (userContainer.width + 20) * -1
                to: root.defaultUserContainerMargin
                duration: Appearance.animation.slow
                easing.type: Appearance.animation.easing
            }
            NumberAnimation {
                target: loginContainer
                property: 'scale'
                // from: 1
                to: 0.9
                duration: Appearance.animation.slow
                easing.type: Appearance.animation.easing
            }
            NumberAnimation {
                target: loginContainer
                property: 'opacity'
                // from: 1
                to: 0
                duration: Appearance.animation.slow
                easing.type: Appearance.animation.easing
            }
        }
    }

    Item {
        id: userContainer

        width: 540
        height: 400

        visible: !root.disableUserSelectionUI
        
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            margins: root.defaultUserContainerMargin
        }

        Repeater {
            model: root.users
            delegate: UserItem {
                foregroundLayer: root

                onUserSelected: {
                    root.changeState(1)
                }
            }
        }
    }

    Item {
        id: loginContainer
        anchors.fill: parent
        scale: 0.9
        opacity: 0
        visible: opacity > 0

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowOpacity: 0.4
            shadowColor: Appearance.colors.m3shadow
            shadowBlur: 1
        }

        ColumnLayout {
            id: loginLayout
            anchors.centerIn: parent
            spacing: 10
            StyledButton {
                visible: !root.disableUserSelectionUI
                Layout.preferredWidth: height
                icon: 'arrow_back'
                iconSize: 20
                radius: passwordInput.radius
                base_bg: Colors.opacify(Appearance.colors.m3surface_container, 0.3)
                base_fg: Appearance.colors.m3on_surface
                hover_bg: Colors.opacify(Appearance.colors.m3surface_container, 0.6)
                onClicked: root.changeState(0)
            }
            ProfileIcon {
                implicitWidth: 140
                implicitHeight: 140
                Layout.alignment: Qt.AlignHCenter
                username: root.users[selectedUser]
                color: Appearance.colors.m3surface_container_high
            }
            StyledText {
                text: root.users[selectedUser]
                font.pixelSize: 32
                font.family: "Outfit SemiBold"
                Layout.alignment: Qt.AlignHCenter
            }
            StyledText {
                id: statusText
                Layout.fillWidth: true
                color: text.includes("Failed") || text.includes("Error")
                    ? Appearance.colors.m3error
                    : Appearance.colors.m3primary
                wrapMode: Text.WordWrap
                visible: text !== ""
                horizontalAlignment: Text.AlignHCenter
            }
            RowLayout {
                Layout.topMargin: 10

                StyledTextField {
                    id: passwordInput
                    Layout.preferredWidth: 400
                    placeholder: "Password"
                    icon: "lock"
                    backgroundColor: Colors.opacify(Appearance.colors.m3surface, 0.2)
                    echoMode: TextField.Password
                    fieldPadding: 15
                    filled: false
                    enabled: !root.authenticating

                    onTextChanged: {
                        if (!root.authenticating)
                            statusText.text = ""
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape && !root.disableUserSelectionUI) {
                            root.changeState(0)
                            event.accepted = true
                        }
                    }

                    Keys.onReturnPressed: root.submitLogin()
                }         
            }
        }
    }

    MouseArea {
        enabled: root.state == 0
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true

        property real scrollAccumulator: 0

        onWheel: event => {
            const delta = event.pixelDelta.y !== 0
                ? event.pixelDelta.y
                : event.angleDelta.y

            scrollAccumulator += delta

            if (scrollAccumulator >= 20)
                root.changeSelectedUser(-1)
            else if (scrollAccumulator <= -20)
                root.changeSelectedUser(1)
            scrollAccumulator = 0
            event.accepted = true
        }
    }

    function submitLogin() {
        if (root.authenticating && !root.awaitingResponse)
            return

        const username = root.users[root.selectedUser]

        if (!username || username.length === 0) {
            statusText.text = "No user selected."
            return
        }

        if (passwordInput.text.length === 0) {
            statusText.text = "Password is empty."
            return
        }

        if (root.awaitingResponse) {
            root.awaitingResponse = false
            root.authenticating = true
            statusText.text = "Authenticating..."
            Greetd.respond(passwordInput.text)
            return
        }

        if (!Greetd.available) {
            statusText.text = "Error: greetd is not available."
            return
        }

        root.authenticating = true
        statusText.text = "Authenticating..."
        Greetd.createSession(username)
    }

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (!message.startsWith('Password:'))
                statusText.text = error ? "Error: " + message : message

            if (responseRequired) {
                if (passwordInput.text.length > 0) {
                    root.awaitingResponse = false
                    Greetd.respond(passwordInput.text)
                } else {
                    root.awaitingResponse = true
                    root.authenticating = false
                    passwordInput.forceActiveFocus()
                }
            }
        }

        function onAuthFailure(message) {
            passwordInput.text = ""
            root.awaitingResponse = false
            root.authenticating = false
            statusText.text = "Failed: " + message
            passwordInput.forceActiveFocus()
        }

        function onReadyToLaunch() {
            var command = ["bash"]

            if (root.selectedSession >= 0 && root.selectedSession < root.sessions.length) {
                var session = root.sessions[root.selectedSession]

                if (session.command && session.command.length > 0)
                    command = [session.command]
            }

            statusText.text = "Launching..."
            _logInfo("launching command: " + command.join(" "))
            Greetd.launch(command)
        }

        function onError(error) {
            root.awaitingResponse = false
            root.authenticating = false
            statusText.text = "Error: " + error
        }
    }

    Process {
        id: getUsersProcess

        running: true
        command: ["bash", "-c", "getent passwd | grep -E ':[0-9]{4}:' | cut -d: -f1"]

        stdout: StdioCollector {
            onStreamFinished: {
                var userList = text.trim().split('\n').filter(u => u.length > 0)
                root.users = userList
                root.selectedUser = Math.max(0, Math.min(root.selectedUser, root.users.length - 1))
                _logInfo('found users: ' + root.users)

                // if there's just one user, just switch to state 1
                if (root.users.length == 1) {
                    root.disableUserSelectionUI = true
                    root.loginTransitionDuration = 0
                    root.changeState(1)
                    root.loginTransitionDuration = Appearance.animation.slow
                    _logInfo('only found 1 user! switching to login screen.')
                }
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
                var sessions = []

                if (lines.length === 0) {
                    sessions = [{
                        name: 'Default Session',
                        command: 'bash'
                    }]
                } else {
                    for (var i = 0; i < lines.length; i++) {
                        var parts = lines[i].split('|||')

                        if (parts.length === 2) {
                            sessions.push({
                                name: parts[0],
                                command: parts[1]
                            })
                        }
                    }
                }

                root.sessions = sessions
                _logInfo('found sessions: ' + root.sessions)

                root.selectedSession = Math.max(0, Math.min(root.selectedSession, root.sessions.length - 1))
            }
        }
    }

    function _logInfo(content) {
        Log.info('windows/greeter/components/ForegroundLayer.qml', content)
    }
    
    function _logWarn(content) {
        Log.warn('windows/greeter/components/ForegroundLayer.qml', content)
    }
}