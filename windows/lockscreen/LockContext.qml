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

    // Only clear failure text when typing; keep lastMessage/accountLocked
    onCurrentTextChanged: showFailure = false;

    function tryUnlock() {
        if (currentText === "") return;

        root.unlockInProgress = true;
        pam.start();
    }

    PamContext {
        id: pam

        configDirectory: "pam"
        config: "password.conf"

        onMessageChanged: {
            if (message.startsWith("The account is locked")) {
                root.lastMessage = message;
                root.accountLocked = true;
            } else if (root.lastMessage && message.endsWith(" left to unlock)")) {
                root.lastMessage += "\n" + message;
                root.accountLocked = true;
            } else if (message.toLowerCase().startsWith("password:") && !root.accountLocked) {
                root.accountLocked = false;
            }
        }

        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.currentText);
            }
        }

        onCompleted: result => {
            if (result == PamResult.Success) {
                // Clear lock and message only on successful login
                root.lastMessage = "";
                root.accountLocked = false;

                root.unlocked();
                root.animate();
            } else {
                root.currentText = "";
                root.showFailure = true;
            }

            root.unlockInProgress = false;
        }
    }
}
