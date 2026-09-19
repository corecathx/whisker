pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root
    // General
    readonly property var devices: Networking.devices.values ?? []
    function isSafe(network) {
        return network.security !== WifiSecurityType.Open
    }
    function getIconFromStrength(strength) {
        const level = Math.min(4, Math.floor(strength * 5));

        return [
            "signal_wifi_0_bar",
            "network_wifi_1_bar",
            "network_wifi_2_bar",
            "network_wifi_3_bar",
            "signal_wifi_4_bar"
        ][level];
    }

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

}