import QtQuick
import QtQuick.Layouts
import qs.components
import qs.modules
import qs.services

BaseCard {
    id: wifiRow
    property var network
    property bool isActive: false
    property bool showConnect: false
    property bool showDisconnect: false
    property bool showPasswordField: false
    property string password: ""

    cardMargin: 0
    cardSpacing: 10
    verticalPadding: 0
    opacity: isActive ? 1 : 1

    function signalIcon(strength, secure) {
        let icon = "";
        if (strength >= 75) icon = "network_wifi";
        else if (strength >= 50) icon = "network_wifi_3_bar";
        else if (strength >= 25) icon = "network_wifi_2_bar";
        else if (strength > 0)   icon = "network_wifi_1_bar";
        else                     icon = "network_wifi_1_bar";
        return icon;
    }

    RowLayout {
        MaterialIcon {
            icon: signalIcon(network.strength, network.isSecure)
            color: Appearance.colors.m3on_background
            font.pixelSize: 32
            MaterialIcon {
                icon: 'lock'
                visible: network.isSecure
                color: Appearance.colors.m3on_background
                font.pixelSize: 12
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 0
            Text {
                text: network.ssid
                font.pixelSize: 16
                font.bold: true
                color: Appearance.colors.m3on_background
            }
            Text {
                text: isActive ? "Connected" : (network.isSecure ? "Secured" : "Open")
                font.pixelSize: 12
                color: isActive ? Appearance.colors.m3primary : Colors.opacify(Appearance.colors.m3on_background, 0.6)
            }
        }

        Item { Layout.fillWidth: true }

        StyledButton {
            visible: showConnect && !showPasswordField
            icon: "link"
            onClicked: {
                if (network.isSecure) {
                    showPasswordField = true;
                } else {
                    Network.connectToNetwork(network.ssid, "");
                }
            }
        }

        StyledButton {
            visible: showDisconnect && !showPasswordField
            icon: "link_off"
            onClicked: Network.disconnectFromNetwork()
        }
    }

    RowLayout {
        visible: showPasswordField
        property bool showPassword: false
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10

        StyledTextField {
            padding: 10
            icon: "password"
            Layout.fillWidth: true
            placeholder: "Enter password"
            echoMode: parent.showPassword ? TextInput.Normal : TextInput.Password
            onTextChanged: wifiRow.password = text
            onAccepted: {
                Network.connectToNetwork(network.ssid, wifiRow.password)
                showPasswordField = false  // hide on enter
            }
        }

        StyledButton {
            icon: parent.showPassword ? "visibility" : "visibility_off"
            onClicked: parent.showPassword = !parent.showPassword
        }

        StyledButton {
            icon: "link"
            onClicked: {
                Network.connectToNetwork(network.ssid, wifiRow.password)
                showPasswordField = false  // hide on connect button
            }
        }
    }

}
