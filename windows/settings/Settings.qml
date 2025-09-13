import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import qs.modules
import qs.components

Scope {
    IpcHandler {
        target: "settings"
        function open() {
            Globals.visible_settingsMenu = true
        }
    }
    LazyLoader {
        active: Globals.visible_settingsMenu
        Window {
            id: root
            property int selectedIndex: 0
            width: 1280
            height: 720
            visible: true
            title: "Whisker Settings"

            color: Appearance.colors.m3background
            onClosing: {
                Globals.visible_settingsMenu = false;
            }

            RowLayout {
                anchors.fill: parent

                Rectangle {
                    Layout.fillHeight: true
                    width: 300
                    color: Appearance.colors.m3surface_container_low

                    Column {
                        anchors.fill: parent
                        anchors.margins: 40
                        spacing: 10

                        Text {
                            text: "Settings"
                            color: Appearance.colors.m3on_surface
                            font.bold: true
                            font.pixelSize: 28
                        }

                        Repeater {
                            model: ListModel {
                                ListElement { icon: "signal_wifi_4_bar"; label: "Wi-Fi" }
                                ListElement { icon: "bluetooth"; label: "Bluetooth" }
                                ListElement { icon: "pets"; label: "Whisker" }
                                ListElement { icon: "desktop_windows"; label: "System" }
                                ListElement { icon: "info"; label: "About" }
                            }

                            delegate: MouseArea {
                                width: parent.width
                                height: 40
                                hoverEnabled: true

                                Rectangle {
                                    radius: 20
                                    anchors.fill: parent

                                    color: root.selectedIndex === index
                                        ? Appearance.colors.m3primary_container
                                        : (containsMouse
                                            ? Colors.opacify(Appearance.colors.m3primary, 0.08)
                                            : "transparent")

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 180
                                            easing.type: Easing.OutQuad
                                        }
                                    }

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 14

                                        MaterialIcon {
                                            icon: model.icon
                                            font.pixelSize: 24
                                            color: root.selectedIndex === index
                                                ? Appearance.colors.m3on_primary_container
                                                : Appearance.colors.m3on_surface_variant
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            text: model.label
                                            font.pixelSize: 16
                                            color: root.selectedIndex === index
                                                ? Appearance.colors.m3on_primary_container
                                                : Appearance.colors.m3on_surface_variant
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }

                                onClicked: {
                                    settingsStack.currentIndex = index
                                    root.selectedIndex = index
                                }
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "! Everything here is TBA !"
                            color: Colors.opacify(Appearance.colors.m3on_surface_variant, 0.6)
                        }
                    }
                }

                StackLayout {
                    id: settingsStack
                    Layout.fillWidth: true
                    Layout.fillHeight: true


                    WifiMenu {}
                    BluetoothMenu {}
                    WhiskerMenu {}
                    SystemMenu {}

                    Rectangle {
                        color: "transparent"
                        anchors.fill: parent

                        AboutMenu {}
                    }
                }
            }
        }
    }
}
