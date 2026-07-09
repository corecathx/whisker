import QtQuick
import QtQuick.Layouts
import qs.components
import qs.modules
import qs.services
import Quickshell
Item {
    id: root
    property string icon: Bluetooth.icon
    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight

    visible: icon !== ""
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
    RowLayout {
        id: container
        MaterialIcon {
            id: iconLabel
            font.pixelSize: 20
            icon: root.icon
            color: Appearance.colors.m3on_background
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
                implicitWidth: 300
                implicitHeight: container.implicitHeight + 10

                ColumnLayout {
                    id: container
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5
                    anchors.topMargin: 5
                    StyledText {
                        text: "Bluetooth"
                        font.bold: true
                        font.pixelSize: 18
                    }
                    SmallSwitch {
                        text: "Enabled"
                        checked: Bluetooth.enabled
                        onToggled: () => { Bluetooth.setEnabled(checked) }
                    }
                    SmallSwitch {
                        text: "Discoverable"
                        checked: Bluetooth.discoverable
                        onToggled: () => { Bluetooth.setDiscoverable(checked) }
                    }
                    SmallSwitch {
                        text: "Scanning"
                        checked: Bluetooth.scanning
                        onToggled: () => {
                            Bluetooth.setScanning(checked)
                        }
                    }
                    Item {height: 4}
                    StyledText {
                        text: Bluetooth.devices.length + " device" + ( Bluetooth.devices.length ? "s" : "") + " found"
                        color: Appearance.colors.m3on_surface_variant
                    }
                    Repeater {
                        model: {
                            return [...Bluetooth.devices].sort((a, b) => {
                                if (a.connected === b.connected)
                                    return 0;
                                return a.connected ? -1 : 1;
                            });
                        }
                        delegate: RowLayout {
                            id: rl
                            required property var modelData

                            MaterialIcon {
                                color: modelData.connected ? Appearance.colors.m3primary : Appearance.colors.m3on_surface
                                icon: Utils.dbusIconToMaterial(modelData.icon)
                            }
                            ColumnLayout {
                                spacing: 0
                                Layout.fillWidth: true
                                StyledText {
                                    Layout.fillWidth: true
                                    color: modelData.connected ? Appearance.colors.m3primary : Appearance.colors.m3on_surface
                                    text: modelData.name
                                    font.bold: modelData.connected
                                    elide: Text.ElideRight
                                    wrapMode: Text.NoWrap
                                }
                                StyledText {
                                    visible: modelData.connected && modelData.batteryAvailable
                                    Layout.fillWidth: true
                                    opacity: 0.7
                                    color: modelData.connected ? Appearance.colors.m3secondary : Appearance.colors.m3on_surface_variant
                                    text: Math.floor(modelData.battery * 100) + "%"
                                    font.pixelSize: 9
                                    elide: Text.ElideRight
                                    wrapMode: Text.NoWrap
                                }
                            }
                            Item {
                                visible: Bluetooth.isChangingState(modelData)
                                implicitWidth: 28
                                implicitHeight: 28
                                LoadingIcon {
                                    size: 16
                                    anchors.centerIn: parent
                                }
                            }
                            StyledButton {
                                implicitHeight: 28
                                visible: !Bluetooth.isChangingState(modelData)
                                icon: modelData.connected ? "link_off" : "link"
                                iconSize: 16
                                base_bg: modelData.connected ? Appearance.colors.m3primary : Appearance.colors.m3surface
                                hover_bg: modelData.connected ? Qt.darker(Appearance.colors.m3primary, 1.1) : Appearance.colors.m3surface_container
                                base_fg: modelData.connected ? Appearance.colors.m3on_primary : Appearance.colors.m3on_surface
                                                     
                                onClicked: {
                                    if (modelData.connected) {
                                        modelData.disconnect()
                                    } else {
                                        modelData.connect();
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
                            Quickshell.execDetached({command:['whisker', 'ipc', 'settings', 'open', 'bluetooth']})
                            popout.hide();
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
                    if (!Bluetooth.defaultAdapter?.enabled)
                        return "Bluetooth is off"
                    if (!Bluetooth.activeDevice)
                        return "Not connected"
                    return "Connected to \"" + (Bluetooth.activeDevice.name ||  Bluetooth.activeDevice.address) + "\""
                }
                color: Appearance.colors.m3on_surface
                font.pixelSize: 14
            }
        }
    }
}
