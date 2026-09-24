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
    opacity: ((device.state === QsBluetooth.BluetoothDeviceState.Connecting ||
             device.state === QsBluetooth.BluetoothDeviceState.Disconnecting)
             || device.pairing ? 0.6 : 1)
             

    MaterialIcon {
        icon: Utils.dbusIconToMaterial(device.icon)
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
        visible: false // for now
        icon: "add"
        onClicked: device.pair()
    }

    StyledButton {
        visible: showRemove
        icon: "delete"
        onClicked: device.forget()
    }
}
