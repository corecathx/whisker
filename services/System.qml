pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: system

    property string name: ""
    property string version: ""
    property string prettyName: ""
    property string logo: ""
    property string id: ""

    Process {
        running: true
        command: ["sh", "-c", "source /etc/os-release && echo \"$NAME|$VERSION|$PRETTY_NAME|$LOGO|$ID\""]
        stdout: StdioCollector {
            onStreamFinished: () => {
                var parts = this.text.trim().split("|")
                if (parts.length >= 5) {
                    system.name = parts[0]
                    system.version = parts[1]
                    system.prettyName = parts[2]
                    system.logo = parts[3]
                    system.id = parts[4]
                }
            }
        }
    }
}
