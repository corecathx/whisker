import QtQuick
import QtQuick.Layouts
import qs.components
import qs.modules
import Quickshell.Bluetooth as QsBluetooth

BaseRowCard {
    id: deviceRow
    property var device
    property string statusText: ""
    property bool usePrimary: false
    property bool showConnect: false
    property bool showDisconnect: false
    property bool showPair: false
    property bool showRemove: false

    cardMargin: 0
    cardSpacing: 10
    verticalPadding: 0
    opacity: device.state === QsBluetooth.BluetoothDeviceState.Connecting ||
             device.state === QsBluetooth.BluetoothDeviceState.Disconnecting ? 0.6 : 1

    function mapBluetoothIcon(dbusIcon, name) {
        Log.info("windows/settings/BluetoothDeviceCard.qml", dbusIcon + ' / ' + name)
        const iconMap = {
            "audio-headset": "headset",
            "audio-headphones": "headphones",
            "input-keyboard": "keyboard",
            "input-mouse": "mouse",
            "input-gaming": "sports_esports",
            "phone": "phone_android",
            "computer": "computer",
            "printer": "print",
            "camera": "photo_camera",
            "unknown": "bluetooth"
        }
        return iconMap[dbusIcon] || "bluetooth";
    }

    MaterialIcon {
        icon: mapBluetoothIcon(device.icon, device.name)
        color: Appearance.colors.m3on_background
        font.pixelSize: 32
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 0
        StyledText {
            text: device.name || device.address
            font.pixelSize: 16
            font.bold: true
            color: Appearance.colors.m3on_background
        }
        StyledText {
            text: statusText
            font.pixelSize: 12
            color: usePrimary ? Appearance.colors.m3primary : Colors.opacify(Appearance.colors.m3on_background, 0.6)
        }
    }

    Item { Layout.fillWidth: true }

    StyledButton {
        visible: showConnect
        icon: "link"
        onClicked: device.connect()
    }

    StyledButton {
        visible: showDisconnect
        icon: "link_off"
        onClicked: device.disconnect()
    }

    StyledButton {
        visible: showPair
        icon: "add"
        onClicked: device.pair()
    }

    StyledButton {
        visible: showRemove
        icon: "delete"
        onClicked: Bluetooth.removeDevice(device)
    }
}
