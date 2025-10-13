import QtQuick
import Quickshell.Io
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules
import qs.components

RowLayout {
    id: root
    spacing: 12
    anchors.margins: 20
    Layout.leftMargin: 20
    Layout.rightMargin: 20

    property bool showText: true
    property string current_mode: "Balanced"

    Component.onCompleted: {
        if (showText) return;

        btn_balanced.text = btn_saver.text = btn_perf.text = ""
    }
    StyledButton {
        id: btn_saver
        text: "Power Saver"
        icon: "energy_savings_leaf"
        checkable: true
        Layout.fillWidth: true
        onToggled: if (checked) {
            btn_balanced.checked = false
            btn_perf.checked = false
            root.current_mode = "Power Saver"

            ppcProc.command[2] = 'power-saver'
            ppcProc.running = true

            notifyProc.message = "Power profile has changed to: Power Saver"
            notifyProc.running = true

            console.log("Current mode:", root.current_mode)
        }
    }

    StyledButton {
        id: btn_balanced
        text: "Balanced"
        icon: "balance"
        checkable: true
        Layout.fillWidth: true
        onToggled: if (checked) {
            btn_saver.checked = false
            btn_perf.checked = false
            root.current_mode = "Balanced"

            ppcProc.command[2] = 'balanced'
            ppcProc.running = true

            notifyProc.message = "Power profile has changed to: Balanced"
            notifyProc.running = true

            console.log("Current mode:", root.current_mode)
        }
    }

    StyledButton {
        id: btn_perf
        text: "Performance"
        icon: "flash_on"
        checkable: true
        Layout.fillWidth: true
        onToggled: if (checked) {
            btn_saver.checked = false
            btn_balanced.checked = false
            root.current_mode = "Performance"

            ppcProc.command[2] = 'performance'
            ppcProc.running = true

            notifyProc.message = "Power profile has changed to: Performance"
            notifyProc.running = true

            console.log("Current mode:", root.current_mode)
        }
    }

    Process {
        id: ppcProc
        command: ['powerprofilesctl', 'set', 'performance']
    }

    Process {
        id: notifyProc
        property string message: ""
        command: ["dunstify", "-i", Utils.getPath('logo.png'), "Whisker", message]
        running: false
    }

    Process {
        id: getProfileProc
        command: ["powerprofilesctl", "get"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let output = this.text.trim()
                root.current_mode = output
                btn_saver.checked = (output === "power-saver")
                btn_balanced.checked = (output === "balanced")
                btn_perf.checked = (output === "performance")
                console.log("Detected current mode:", output)
            }
        }

    }
}
