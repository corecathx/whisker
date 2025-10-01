pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property list<AccessPoint> networks: []
    readonly property list<string> savedNetworks: []
    readonly property AccessPoint active: networks.find(n => n.active) ?? null
    property bool wifiEnabled: true
    readonly property bool scanning: rescanProc.running

    property string lastNetworkAttempt: ""
    property string lastErrorMessage: ""
    property string message: ""
    property string icon: {
        if (!active) return "signal_wifi_off";

        let icon = "";
        if (active.strength >= 75) icon = "network_wifi";
        else if (active.strength >= 50) icon = "network_wifi_3_bar";
        else if (active.strength >= 25) icon = "network_wifi_2_bar";
        else if (active.strength > 0)   icon = "network_wifi_1_bar";
        else                            icon = "network_wifi_1_bar";
        return icon;
    }

    function enableWifi(enabled: bool): void {
        const cmd = enabled ? "on" : "off";
        enableWifiProc.exec(["nmcli", "radio", "wifi", cmd]);
    }

    function toggleWifi(): void {
        const cmd = wifiEnabled ? "off" : "on";
        enableWifiProc.exec(["nmcli", "radio", "wifi", cmd]);
    }

    function rescanWifi(): void {
        rescanProc.running = true;
    }

    function connectToNetwork(ssid: string, password: string): void {
        root.lastNetworkAttempt = ssid;
        root.lastErrorMessage = "";
        root.message = "";

        if (password && password.length > 0) {
            connectProc.exec(["nmcli", "dev", "wifi", "connect", ssid, "password", password]);
        } else {
            connectProc.exec(["nmcli", "dev", "wifi", "connect", ssid]);
        }
    }

    function disconnectFromNetwork(): void {
        if (active) {
            disconnectProc.exec(["nmcli", "connection", "down", active.ssid]);
        }
    }

    function getWifiStatus(): void {
        wifiStatusProc.running = true;
    }

    Process {
        running: true
        command: ["nmcli", "m"]
        stdout: SplitParser { onRead: getNetworks.running = true }
    }

    Process {
        id: wifiStatusProc
        running: true
        command: ["nmcli", "radio", "wifi"]
        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = text.trim() === "enabled";

                // Clear error if Wi-Fi disabled
                if (!root.wifiEnabled) {
                    root.lastErrorMessage = "";
                    root.message = "";
                    root.lastNetworkAttempt = "";
                }
            }
        }
    }

    Process {
        id: enableWifiProc
        onExited: {
            root.getWifiStatus();
            getNetworks.running = true;
            getSavedNetworks.running = true;
        }
    }

    Process {
        id: rescanProc
        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        onExited: {
            getNetworks.running = true;
            getSavedNetworks.running = true;

            // Clear errors if no networks found
            if (!root.wifiEnabled || root.networks.length === 0) {
                root.lastErrorMessage = "";
                root.message = "";
            }
        }
    }

    Process {
        id: connectProc
        stdout: StdioCollector { }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.includes("Error") || text.includes("incorrect")) {
                    root.lastErrorMessage = "Incorrect password";
                }
            }
        }
        onExited: {
            if (exitCode === 0) {
                root.message = "ok";
                root.lastErrorMessage = "";
            } else {
                root.message = root.lastErrorMessage !== "" ? root.lastErrorMessage : "Connection failed";
            }
        }
    }

    Process { id: disconnectProc; stdout: SplitParser { onRead: getNetworks.running = true } }

    Process {
        id: getSavedNetworks
        running: true
        command: ["nmcli", "-g", "NAME,TYPE", "connection", "show"]
        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                const wifiConnections = lines
                    .map(line => line.split(":"))
                    .filter(parts => parts[1] === "802-11-wireless")
                    .map(parts => parts[0]);

                root.savedNetworks = wifiConnections;
            }
        }
    }

    Process {
        id: getNetworks
        running: true
        command: ["nmcli", "-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY", "d", "w"]
        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
        stdout: StdioCollector {
            onStreamFinished: {
                const PLACEHOLDER = "STRINGWHICHHOPEFULLYWONTBEUSED";
                const rep = new RegExp("\\\\:", "g");
                const rep2 = new RegExp(PLACEHOLDER, "g");

                const allNetworks = text.trim().split("\n").map(n => {
                    const net = n.replace(rep, PLACEHOLDER).split(":");
                    return {
                        active: net[0] === "yes",
                        strength: parseInt(net[1]),
                        frequency: parseInt(net[2]),
                        ssid: net[3]?.replace(rep2, ":") ?? "",
                        bssid: net[4]?.replace(rep2, ":") ?? "",
                        security: net[5] ?? "",
                        saved: root.savedNetworks.includes(net[3] ?? "")
                    };
                }).filter(n => n.ssid && n.ssid.length > 0);

                // Deduplicate networks
                const networkMap = new Map();
                for (const network of allNetworks) {
                    const existing = networkMap.get(network.ssid);
                    if (!existing) {
                        networkMap.set(network.ssid, network);
                    } else {
                        if (network.active && !existing.active) {
                            networkMap.set(network.ssid, network);
                        } else if (!network.active && !existing.active && network.strength > existing.strength) {
                            networkMap.set(network.ssid, network);
                        }
                    }
                }

                const networks = Array.from(networkMap.values());
                const rNetworks = root.networks;

                const destroyed = rNetworks.filter(rn => !networks.find(n => n.frequency === rn.frequency && n.ssid === rn.ssid && n.bssid === rn.bssid));
                for (const network of destroyed)
                    rNetworks.splice(rNetworks.indexOf(network), 1).forEach(n => n.destroy());

                for (const network of networks) {
                    const match = rNetworks.find(n => n.frequency === network.frequency && n.ssid === network.ssid && n.bssid === network.bssid);
                    if (match) {
                        match.lastIpcObject = network;
                    } else {
                        rNetworks.push(apComp.createObject(root, { lastIpcObject: network }));
                    }
                }
            }
        }
    }

    component AccessPoint: QtObject {
        required property var lastIpcObject
        readonly property string ssid: lastIpcObject.ssid
        readonly property string bssid: lastIpcObject.bssid
        readonly property int strength: lastIpcObject.strength
        readonly property int frequency: lastIpcObject.frequency
        readonly property bool active: lastIpcObject.active
        readonly property string security: lastIpcObject.security
        readonly property bool isSecure: security.length > 0
        readonly property bool saved: lastIpcObject.saved
    }

    Component { id: apComp; AccessPoint { } }
}
