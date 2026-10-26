import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root

    signal unlocked()
    signal animate()
    signal failed()

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property string lastMessage: ""
    property bool accountLocked: false

    property bool authenticated: false

    onCurrentTextChanged: showFailure = false

    function startAuthentication() {
        authenticated = false;
        currentText = "";
        showFailure = false;

        if (passwordPam.active)
            passwordPam.abort();

        if (fingerprintPam.active)
            fingerprintPam.abort();

        passwordPam.start();
        fingerprintPam.start();
    }

    function tryUnlock() {
        if (!passwordPam.active || !passwordPam.responseRequired)
            return;

        passwordPam.respond(currentText);
    }

    function unlockSuccess() {
        if (authenticated)
            return;

        authenticated = true;

        unlockInProgress = false;
        lastMessage = "";
        accountLocked = false;

        passwordPam.abort();
        fingerprintPam.abort();

        unlocked();
        animate();
    }

    // passwd
    PamContext {
        id: passwordPam

        configDirectory: "pam"
        config: "passwd.conf"

        onMessageChanged: {
            if (message.startsWith("The account is locked")) {
                root.lastMessage = message;
                root.accountLocked = true;
            } else if (
                root.lastMessage &&
                message.endsWith(" left to unlock)")
            ) {
                root.lastMessage += "\n" + message;
                root.accountLocked = true;
            } else if (
                message.toLowerCase().startsWith("password:")
                && !root.accountLocked
            ) {
                root.accountLocked = false;
            }
        }

        onCompleted: result => {
            switch (result) {
                case PamResult.Success:
                    root.unlockSuccess();
                    break;

                default:
                    if (!root.authenticated) {
                        root.currentText = "";
                        root.showFailure = true;
                        start();
                    }
            }
        }
    }

    // fprintd
    PamContext {
        id: fingerprintPam

        configDirectory: "pam"
        config: "fprintd.conf"

        onCompleted: result => {
            switch (result) {
                case PamResult.Success:
                    root.unlockSuccess();
                    break;

                default:
                    if (!root.authenticated) {
                        start();
                    }
            }
        }
    }
}