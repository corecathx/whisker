pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root
    // General
    readonly property var devices: Networking.devices.values ?? []
    property bool debugConnectivity: true

    readonly property var connectivity: Networking.connectivity

    // Wi-Fi
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property list<WifiDevice> wifiDevices: devices.filter(d => d.type === DeviceType.Wifi)
    readonly property WifiDevice wifiDevice: {
        wifiDevices.find(d => d.connected) 
        ?? wifiDevices[0] 
        ?? null
    }
    readonly property WifiNetwork wifiNetwork: wifiDevice?.networks?.values?.find(n => n.connected) ?? null

    function enableWifi(enabled: bool): void {
        Networking.wifiEnabled = enabled;
    }

    // Wired
    readonly property list<WiredDevice> wiredDevices: devices.filter(d => d.type === DeviceType.Wired)
    readonly property WiredDevice wiredDevice: {
        wiredDevices.find(d => d.connected)
        ?? wiredDevices[0]
        ?? null
    }
    readonly property Network wiredNetwork: wiredDevice?.network ?? null

    Component.onCompleted: {//
        console.log("[Network] devices:", devices.length)
        for (const d of devices) {
            console.log(d.name, d.type)
        }
    }
    /////////////////////////////////

    readonly property list<Connection> connections: []
    readonly property list<string> savedNetworks: []
    readonly property Connection active: null

    readonly property bool scanning: false

    property string lastNetworkAttempt: ""
    property string lastErrorMessage: ""
    property string message: ""

    readonly property string icon: ""
    readonly property string wifiLabel: ""
    readonly property string wifiStatus: ""
    readonly property string label: ""
    readonly property string status: ""


    function toggleWifi(): void {}

    function rescan(): void {}

    function connect(connection: Connection, password: string): void {}

    function disconnect(): void {}

    component Connection: QtObject {
        readonly property string type: ""
        readonly property string name: ""
        readonly property string uuid: ""
        readonly property string device: ""
        readonly property bool active: false
        readonly property int strength: 0
        readonly property int frequency: 0
        readonly property string bssid: ""
        readonly property string security: ""
        readonly property bool isSecure: false
        readonly property bool saved: false
    }
}