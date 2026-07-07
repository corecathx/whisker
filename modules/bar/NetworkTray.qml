import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import Quickshell.Networking as QsNet
import qs.components
import qs.modules
import qs.services

Item {
    id: root
    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    visible: !!Network.wifiDevice || !!Network.wiredDevice
    Layout.preferredWidth: visible ? implicitWidth : 0
    Layout.preferredHeight: visible ? implicitHeight : 0

    component SmallSwitch: RowLayout {
        id: ss
        property alias text: label.text
        property alias checked: sw.checked
        property var onToggled: () => {}
        Layout.fillWidth: true
        StyledText {
            id: label
        }
        Item {
            Layout.fillWidth: true
        }
        StyledSwitch {
            id: sw
            width: 44
            height: 25
            thumbOffMargin: 4
            thumbOnMargin: 5
            onToggled: () => { ss.onToggled() }
        }
    }

    MouseArea {
        id: mArea
        anchors.fill: parent
        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (popout.isVisible)
                popout.hide()
            else
                popout.show()
        }
    }

    StyledPopout {
        id: popout
        hoverTarget: hover
        interactable: true
        hCenterOnItem: true
        requiresHover: false
        Component {
            Item {
                id: popoutParent
                property int state: 0 // 0 = list; 1 = password_entry
                property var targetNetwork: null
                implicitWidth: 300
                implicitHeight: {
                    switch (state) {
                        case 0: 
                            return networkListContainer.implicitHeight + 10
                        case 1:
                            return passwordEntryContainer.implicitHeight + 10
                        default: 
                            return 10;
                    }
                }

                ColumnLayout {
                    id: networkListContainer
                    visible: popoutParent.state === 0
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5
                    anchors.topMargin: 5
                    StyledText {
                        text: "Wi-Fi"
                        font.bold: true
                        font.pixelSize: 18
                    }
                    SmallSwitch {
                        text: "Enabled"
                        checked: Network.wifiEnabled
                        onToggled: () => { Network.enableWifi(checked) }
                    }
                    SmallSwitch {
                        text: "Scanning"
                        checked: Network.wifiDevice.scannerEnabled
                        onToggled: () => {
                            Network.wifiDevice.scannerEnabled = checked
                        }
                    }
                    Item {height: 4}
                    StyledText {
                        text: Network.wifiDevice.networks.values.length + " network" + ( Network.wifiDevice.networks.values.length ? "s" : "") + " found"
                        color: Appearance.colors.m3on_surface_variant
                    }
                    Repeater {
                        model: Network.wifiDevice.networks
                        delegate: RowLayout {
                            id: rl
                            required property var modelData

                            MaterialIcon {
                                color: modelData.connected ? Appearance.colors.m3primary : Appearance.colors.m3on_surface
                                icon: Network.getIconFromStrength(modelData.signalStrength)
                                MaterialIcon {
                                    icon: 'lock'
                                    visible: Network.isSafe(modelData)
                                    color: Appearance.colors.m3on_background
                                    font.pixelSize: 12
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                }
                            }

                            StyledText {
                                color: modelData.connected ? Appearance.colors.m3primary : Appearance.colors.m3on_surface
                                text: modelData.name
                                font.bold: modelData.connected
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                            Item {
                                visible: modelData.stateChanging
                                implicitWidth: 28
                                implicitHeight: 28
                                LoadingIcon {
                                    size: 16
                                    anchors.centerIn: parent
                                }
                            }
                            StyledButton {
                                implicitHeight: 28
                                visible: !modelData.stateChanging
                                icon: modelData.connected ? "link_off" : "link"
                                iconSize: 16
                                base_bg: modelData.connected ? Appearance.colors.m3primary : Appearance.colors.m3surface
                                hover_bg: modelData.connected ? Qt.darker(Appearance.colors.m3primary, 1.1) : Appearance.colors.m3surface_container
                                base_fg: modelData.connected ? Appearance.colors.m3on_primary : Appearance.colors.m3on_surface
                                                     
                                onClicked: {
                                    if (modelData.connected) {
                                        modelData.disconnect()
                                    } else {
                                        if (!Network.isSafe(modelData) || modelData.known) {
                                            modelData.connect();
                                        } else {
                                            popoutParent.state = 1;
                                            popoutParent.targetNetwork = modelData;
                                        }
                                    }

                                }
                            }
                        }
                    }
                    Item {height: 4}
                    StyledButton {
                        Layout.fillWidth: true
                        secondary: true
                        implicitHeight: 28
                        icon: "settings"
                        text: "Open settings"
                        iconSize: 16
                        onClicked: () => {
                            Quickshell.execDetached({command:['whisker', 'ipc', 'settings', 'open', 'wi-fi']})
                            popout.hide();
                        }
                    }
                }
                ColumnLayout {
                    id: passwordEntryContainer
                    property string password: ""
                    visible: popoutParent.state === 1
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5
                    anchors.topMargin: 5
                    spacing: 5
                    StyledText {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: popoutParent.targetNetwork.name
                        font.bold: true
                        font.pixelSize: 18
                    }
                    RowLayout {
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
                            onTextChanged: passwordEntryContainer.password = text
                            onAccepted: {
                                popoutParent.targetNetwork.connectWithPsk(passwordEntryContainer.password);
                                popoutParent.state = 0;
                                popoutParent.targetNetwork = null;
                            }
                        }
                        StyledButton {
                            icon: parent.showPassword ? "visibility" : "visibility_off"
                            onClicked: parent.showPassword = !parent.showPassword
                        }

                    }
                    RowLayout {
                        Layout.fillWidth: true
                        StyledButton {
                            secondary: true
                            Layout.fillWidth: true
                            implicitHeight: 28
                            implicitWidth: 0
                            text: "Cancel"
                            onClicked: {
                                popoutParent.state = 0;
                                popoutParent.targetNetwork = null;
                            }
                        }     
                        StyledButton {
                            id: btnConfirm
                            Layout.fillWidth: true
                            implicitWidth: 0
                            implicitHeight: 28
                            text: "Connect"
                            onClicked: {
                                popoutParent.targetNetwork.connectWithPsk(passwordEntryContainer.password);
                                popoutParent.state = 0;
                                popoutParent.targetNetwork = null;
                            }
                        }          
                    }

                }
            }
        }
    }
    HoverHandler {
        id: hover
    }

    StyledPopout {
        hoverTarget: hover
        hCenterOnItem: true
        Component {
            StyledText {
                text: {
                    if (!Network.wifiNetwork && !Network.wiredNetwork) {
                        if (!Network.wifiEnabled)
                            return "Wi-Fi is off";
                        return "Not connected";
                    }

                    switch (Network.connectivity) {
                    case QsNet.NetworkConnectivity.Portal:
                        return "Sign in to this network";

                    case QsNet.NetworkConnectivity.Limited:
                        return "Limited internet access";

                    case QsNet.NetworkConnectivity.None:
                        return "No internet access";

                    case QsNet.NetworkConnectivity.Unknown:
                        return "Checking connectivity...";
                    }

                    if (Network.wiredNetwork)
                        return "Connected via Ethernet";

                    return `Connected to "${Network.wifiNetwork.name}"`;
                }
                color: Appearance.colors.m3on_surface
                font.pixelSize: 14
            }
        }
    }

    RowLayout {
        id: container
        MaterialIcon {
            id: icon
            font.pixelSize: 20
            icon: {
                switch (Network.connectivity) {
                    case QsNet.NetworkConnectivity.Portal:
                        return "wifi_lock";

                    case QsNet.NetworkConnectivity.Limited:
                        return "wifi_find";

                    case QsNet.NetworkConnectivity.None:
                        return "signal_wifi_off";

                    case QsNet.NetworkConnectivity.Unknown:
                        return "hourglass_top";
                }

                if (Network.wiredNetwork)
                    return "settings_ethernet";

                if (!Network.wifiEnabled)
                    return "signal_wifi_off";

                if (!Network.wifiNetwork)
                    return "signal_wifi_bad";

                return Network.getIconFromStrength(Network.wifiNetwork.signalStrength);
            }
            color: Appearance.colors.m3on_background
        }
    }
}