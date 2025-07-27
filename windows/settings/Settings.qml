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

            color: Colors.background
            onClosing: {
                Globals.visible_settingsMenu = false;
            }

            RowLayout {
                anchors.fill: parent

                Rectangle {
                    radius: 20
                    Layout.fillHeight: true
                    width: 300
                    color: Colors.opacify(Colors.accent, 0.2)

                    Column {
                        anchors.fill: parent
                        anchors.margins: 40
                        spacing: 10

                        Text {
                            text: "Settings"
                            color: Colors.foreground
                            font.bold: true
                            font.pixelSize: 30
                        }

                        Repeater {
                            model: ListModel {
                                ListElement { icon: "signal_wifi_4_bar"; label: "Wi-Fi" }
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
                                        ? Colors.opacify(Colors.accent, 0.5)
                                        : (pressed
                                            ? Colors.opacify(Colors.accent, 0)
                                            : (containsMouse
                                                ? Colors.opacify(Colors.accent, 0.3)
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

                                        MaterialSymbol {
                                            icon: model.icon
                                            font.pixelSize: 24
                                            color: Colors.foreground
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            text: model.label
                                            color: Colors.foreground
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
                        anchors.fill: parent

                        AboutMenu {}
                    }
                }
            }
        }
    }
}

