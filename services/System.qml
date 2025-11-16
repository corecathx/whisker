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
    property real uptime: 0
    property string qsVersion: ''

    Process {
        running: true
        command: ['qs', '--version']
        stdout: StdioCollector {
            onStreamFinished: () => {
                system.qsVersion = this.text.trim().split(',')[0].trim().replace("quickshell ", "");
            }
        }
    }

    Process {
        running: true
        command: ["sh", "-c", "source /etc/os-release && echo \"$NAME|$VERSION|$PRETTY_NAME|$LOGO|$ID\""]
        stdout: StdioCollector {
            onStreamFinished: () => {
                var parts = this.text.trim().split("|");
                if (parts.length >= 5) {
                    system.name = parts[0];
                    system.version = parts[1];
                    system.prettyName = parts[2];
                    system.logo = parts[3];
                    system.id = parts[4];
                }
            }
        }
    }

    FileView {
        path: '/proc/uptime'
        watchChanges: true
        onFileChanged: {
            system.uptime = parseFloat(text().trim().split(" ")[0]);
            console.log("updated");
        }
        onLoaded: system.uptime = parseFloat(text().trim().split(" ")[0])
    }
}
