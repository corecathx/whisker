pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property list<VpnConnection> connections: []
    readonly property VpnConnection active: connections.find(c => c.active) ?? null
    property string lastVpnAttempt: ""
    property string lastErrorMessage: ""
    property string message: ""

    function connectVpn(name: string): void {
        root.lastVpnAttempt = name;
        root.lastErrorMessage = "";
        root.message = "";

        connectProc.exec(["nmcli", "connection", "up", name]);
    }

    function disconnectVpn(): void {
        if (active) {
            disconnectProc.exec(["nmcli", "connection", "down", active.name]);
        }
    }

    function refreshVpnList(): void {
        getVpnConnections.running = true;
    }

    function importWireguard(filePath: string): void {
        if (!filePath || filePath.length === 0) {
            root.lastErrorMessage = "No file selected";
            return;
        }

        importProc.exec(["nmcli", "connection", "import", "type", "wireguard", "file", filePath]);
    }

    Process {
        id: connectProc
        stdout: StdioCollector { }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.includes("Error")) {
                    root.lastErrorMessage = text.trim();
                }
            }
        }
        onExited: {
            if (exitCode === 0) {
                root.message = "ok";
                root.lastErrorMessage = "";
                root.refreshVpnList();
            } else {
                root.message = root.lastErrorMessage !== "" ? root.lastErrorMessage : "Connection failed";
            }
        }
    }

    Process {
        id: disconnectProc
        onExited: {
            root.refreshVpnList();
        }
    }

    Process {
        id: getVpnConnections
        running: true
        command: ["nmcli", "-g", "NAME,TYPE,DEVICE", "connection", "show"]
        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                const vpnList = lines
                    .map(line => line.split(":"))
                    .filter(parts => parts[1] === "vpn")
                    .map(parts => ({
                        name: parts[0],
                        device: parts[2] || "",
                        active: (parts[2] && parts[2].length > 0)
                    }));

                const destroyed = root.connections.filter(c => !vpnList.find(n => n.name === c.name));
                for (const conn of destroyed)
                    root.connections.splice(root.connections.indexOf(conn), 1).forEach(n => n.destroy());

                for (const conn of vpnList) {
                    const match = root.connections.find(c => c.name === conn.name);
                    if (match) {
                        match.lastIpcObject = conn;
                    } else {
                        root.connections.push(vpnComp.createObject(root, { lastIpcObject: conn }));
                    }
                }
            }
        }
    }

    Process {
        id: importProc
        stdout: StdioCollector { }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.includes("Error")) {
                    root.lastErrorMessage = text.trim();
                }
            }
        }
        onExited: {
            if (exitCode === 0) {
                root.message = "WireGuard imported successfully";
                root.lastErrorMessage = "";
                root.refreshVpnList();
            } else {
                root.message = root.lastErrorMessage !== "" ? root.lastErrorMessage : "Import failed";
            }
        }
    }

    component VpnConnection: QtObject {
        required property var lastIpcObject
        readonly property string name: lastIpcObject.name
        readonly property string device: lastIpcObject.device
        readonly property bool active: lastIpcObject.active
    }

    Component { id: vpnComp; VpnConnection { } }
}
