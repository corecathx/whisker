import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import qs.modules
import qs.components

Scope {
    LazyLoader {
        active: Globals.visible_settingsMenu
        Window {
            id: root
            property int selectedIndex: 0
            width: 900
            height: 700
            visible: true
            title: "Whisker Settings"

            color: Appearance.panel_color
            onClosing: {
                Globals.visible_settingsMenu = false;
            }

            RowLayout {
                anchors.fill: parent

                Rectangle {
                    radius: 20
                    Layout.fillHeight: true
                    width: 300
                    color: Colors.opacify(Appearance.colors.m3primary, 0.2)

                    Column {
                        anchors.fill: parent
                        anchors.margins: 40
                        spacing: 10

                        Text {
                            text: "Settings"
                            color: Appearance.colors.m3on_background
                            font.bold: true
                            font.pixelSize: 30
                        }

                        Repeater {
                            model: ListModel {
                                ListElement { icon: "signal_wifi_4_bar"; label: "Wi-Fi" }
                                ListElement { icon: "bluetooth"; label: "Bluetooth" }
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
                                        ? Colors.opacify(Appearance.colors.m3primary, 0.5)
                                        : (pressed
                                            ? Colors.opacify(Appearance.colors.m3primary, 0)
                                            : (containsMouse
                                                ? Colors.opacify(Appearance.colors.m3primary, 0.3)
                                                : "transparent"))

                                    Behavior on color{
                                        ColorAnimation {
                                            duration: 200
                                            easing.type: Easing.OutQuad
                                        }
                                    }

                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 10

                                        MaterialIcon {
                                            icon: model.icon
                                            font.pixelSize: 24
                                            color: Appearance.colors.m3on_background
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            text: model.label
                                            color: Appearance.colors.m3on_background
                                            font.pixelSize: 16
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
                            text: "! Everything here is TBA !"
                            color: Colors.opacify(Appearance.colors.m3on_background, 0.5)
                        }
                    }
                }

                StackLayout {
                    id: settingsStack
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        color: "transparent"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        WifiMenu {
                            anchors.fill: parent
                            anchors.margins: 40
                        }
                    }
                    
                    Rectangle {
                        color: "transparent"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        BluetoothMenu {
                            anchors.fill: parent
                            anchors.margins: 40
                        }
                    }

                    Rectangle {
                        color: "transparent"
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        SystemMenu {
                            anchors.fill: parent
                            anchors.margins: 40
                        }
                    }

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

