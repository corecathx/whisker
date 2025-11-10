import QtQuick
import QtQuick.Layouts
import qs.components
import qs.modules
import qs.services

BaseCard {
    id: networkRow
    property var connection
    property bool isActive: false
    property bool showConnect: false
    property bool showDisconnect: false
    property bool showPasswordField: false
    property string password: ""

    cardMargin: 0
    cardSpacing: 10
    verticalPadding: 0

    function signalIcon(strength, secure) {
        if (connection.type === "ethernet") return "settings_ethernet";

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
            icon: signalIcon(connection.strength, connection.isSecure)
            color: Appearance.colors.m3on_background
            font.pixelSize: 32
            MaterialIcon {
                icon: 'lock'
                visible: connection.type === "wifi" && connection.isSecure
                color: Appearance.colors.m3on_background
                font.pixelSize: 12
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }
        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 0
            StyledText {
                text: connection.name
                font.pixelSize: 16
                font.bold: true
                color: Appearance.colors.m3on_background
            }
            StyledText {
                text: {
                    if (isActive) return "Connected";
                    if (connection.type === "ethernet") return connection.device || "Ethernet";
                    return connection.isSecure ? "Secured" : "Open";
                }
                font.pixelSize: 12
                color: isActive ? Appearance.colors.m3primary : Colors.opacify(Appearance.colors.m3on_background, 0.6)
            }
        }
        Item { Layout.fillWidth: true }
        StyledButton {
            visible: showConnect && !showPasswordField
            icon: "link"
            onClicked: {
                if (connection.type === "ethernet") {
                    Network.connect(connection, "");
                } else if (connection.isSecure) {
                    showPasswordField = true;
                } else {
                    Network.connect(connection, "");
                }
            }
        }
        StyledButton {
            visible: showDisconnect && !showPasswordField
            icon: "link_off"
            onClicked: Network.disconnect()
        }
    }
    RowLayout {
        visible: showPasswordField && connection.type === "wifi"
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
            onTextChanged: networkRow.password = text
            onAccepted: {
                Network.connect(connection, networkRow.password)
                showPasswordField = false
            }
        }
        StyledButton {
            icon: parent.showPassword ? "visibility" : "visibility_off"
            onClicked: parent.showPassword = !parent.showPassword
        }
        StyledButton {
            icon: "link"
            onClicked: {
                Network.connect(connection, networkRow.password)
                showPasswordField = false
            }
        }
    }
}
