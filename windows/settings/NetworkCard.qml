import QtQuick
import QtQuick.Layouts
import Quickshell.Networking as QsNet
import qs.components
import qs.modules
import qs.services

BaseCard {
    id: root
    required property var connection
    property var menu: null

    Connections {
        target: connection
        function onConnectionFailed(reason) {
            if (!connection.known) connection.forget();
            menu.error = true
            menu.errorNetworkName = connection.name
            menu.errorMessage = QsNet.ConnectionFailReason.toString(reason)
            console.log("Connection failed:", reason)
        }
    }

    property bool isActive: false
    property bool showConnect: false
    property bool showDisconnect: false
    property bool showPasswordField: false
    property string password: ""

    onConnectionChanged: {
        console.log("NETWORKCARD.connection =", connection)
    }
    cardMargin: 0
    cardSpacing: 10
    verticalPadding: 0

    function signalIcon(strength) {
        const level = Math.min(4, Math.floor(strength * 5));

        return [
            "signal_wifi_0_bar",
            "network_wifi_1_bar",
            "network_wifi_2_bar",
            "network_wifi_3_bar",
            "signal_wifi_4_bar"
        ][level];
    }

    RowLayout {
        MaterialIcon {
            icon: root.signalIcon(root.connection.signalStrength)
            color: Appearance.colors.m3on_background
            font.pixelSize: 32
            MaterialIcon {
                icon: 'lock'
                 visible: connection.security !== QsNet.WifiSecurityType.Open
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
                    if (isActive)
                        return "Connected";

                    return QsNet.WifiSecurityType.toString(connection.security) + (connection.known ? " (Known)" : "");
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
                menu.error = false
                if (connection.security === QsNet.WifiSecurityType.Open || connection.known) {
                    connection.connect();
                } else {
                    showPasswordField = true;
                }
            }
        }
        StyledButton {
            visible: showDisconnect && !showPasswordField
            icon: "link_off"
            onClicked: {
                menu.error = false
                connection.disconnect()
            }
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
            onTextChanged: root.password = text
            onAccepted: {
                menu.error = false
                root.connection.connectWithPsk(root.password);
                showPasswordField = false;
            }
        }
        StyledButton {
            icon: parent.showPassword ? "visibility" : "visibility_off"
            onClicked: parent.showPassword = !parent.showPassword
        }
        StyledButton {
            icon: "link"
            onClicked: {
                menu.error = false
                root.connection.connectWithPsk(root.password);

                showPasswordField = false
            }
        }
    }
}
