import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import qs.modules
import qs.components
import qs.services

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
            onClosing: Globals.visible_settingsMenu = false

            property var menuModel: {
                // var raw = [
                //     { header: true, label: "Connections" },
                //     { icon: "signal_wifi_4_bar", label: "Wi-Fi" },
                //     { icon: "bluetooth", label: "Bluetooth" },
                //     { icon: "vpn_key", label: "VPN" },
                //     { header: true, label: "System" },
                //     { icon: "volume_up", label: "Sounds" },
                //     { icon: "battery_full", label: "Battery" },
                //     { icon: "memory", label: "Performance" },
                //     { icon: "lock", label: "Security" },
                //     { icon: "schedule", label: "Date & Time" },
                //     { header: true, label: "Customization" },
                //     { icon: "wallpaper", label: "Wallpaper" },
                //     { icon: "palette", label: "Colors" },
                //     { icon: "widgets", label: "Bar" },
                //     { icon: "contrast", label: "Dark Mode" },
                //     { header: true, label: "About" },
                //     { icon: "info", label: "About" },
                //     { icon: "update", label: "System Updates" }
                // ];

                var raw = [
                    { header: true, label: "Connections" },
                    { icon: "signal_wifi_4_bar", label: "Wi-Fi" },
                    { icon: "bluetooth", label: "Bluetooth" },
                    { icon: "vpn_key", label: "VPN" },
                    { header: true, label: "System" },
                    { icon: "volume_up", label: "Sounds" },
                    { icon: "power", label: "Power" },
                    { header: true, label: "Customization" },
                    { icon: "wallpaper", label: "Wallpaper" },
                    { icon: "palette", label: "Colors" },
                    { icon: "widgets", label: "Bar" },
                    { header: true, label: "About" },
                    { icon: "info", label: "About" }
                ];

                var pageCounter = 0;
                return raw.map(function(item) {
                    item.page = item.header ? -1 : pageCounter++;
                    return item
                });
            }

            RowLayout {
                anchors.fill: parent

                Rectangle {
                    id: sidebarBG
                    Layout.fillHeight: true
                    width: 350
                    color: Appearance.colors.m3surface_container_low

                    Column {
                        anchors.fill: parent
                        anchors.margins: 40
                        spacing: 5

                        Text {
                            text: "Settings"
                            color: Appearance.colors.m3on_surface
                            font.family: "Outfit ExtraBold"
                            font.pixelSize: 28
                        }
                        BaseCard {
                            id: userCard
                            cardMargin: 10
                            useAnims: false
                            cardSpacing: 0
                            verticalPadding: 20
                            property bool opened: false

                            property bool hovered: mouseArea.containsMouse

                            color: hovered 
                                ? Appearance.colors.m3surface_container_high 
                                : Appearance.colors.m3surface_container

                            RowLayout {
                                spacing: 10
                                ClippingRectangle {
                                    radius: 100
                                    color: "transparent"

                                    Layout.preferredWidth: userCard.opened ? 60 : 40
                                    Layout.preferredHeight: userCard.opened ? 60 : 40

                                    Behavior on Layout.preferredWidth { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic } }
                                    Behavior on Layout.preferredHeight { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic } }

                                    IconImage {
                                        anchors.fill: parent
                                        source: Appearance.profileImage
                                    }
                                }

                                ColumnLayout {
                                    spacing: 2
                                    Text {
                                        text: Quickshell.env("USER")
                                        color: Appearance.colors.m3on_surface
                                        font.pixelSize: 22
                                        font.family: "Outfit SemiBold"
                                    }
                                    RowLayout {
                                        visible: userCard.opened
                                        Image {
                                            sourceSize: Qt.size(20, 20)
                                            source:  Quickshell.iconPath(System.logo)
                                        }
                                        Text {
                                            text: System.prettyName
                                            color: Colors.opacify(Appearance.colors.m3on_surface, 0.7)
                                            font.pixelSize: 12
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true   // <-- important
                                onClicked: userCard.opened = !userCard.opened
                            }
                        }

                        Repeater {
                            model: root.menuModel

                            delegate: Item {
                                id: itemParent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: modelData.header ? 30 : 40

                                property bool hovered: mouseArea.containsMouse
                                property bool selected: root.selectedIndex === modelData.page && modelData.page !== -1

                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: modelData.header ?? false
                                    text: modelData.label
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: Colors.opacify(Appearance.colors.m3on_surface, 0.6)
                                }

                                Rectangle {
                                    id: sidebarItemBG
                                    anchors.fill: parent
                                    visible: !modelData.header
                                    color: selected
                                           ? Appearance.colors.m3primary
                                           : (hovered
                                               ? Appearance.colors.m3surface_container_high
                                               : Appearance.colors.m3surface_container_low)
                                    radius: 20
                                    Behavior on color { ColorAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic }}
                                }

                                RowLayout {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.topMargin: (parent.height - height) * 0.5 // lol
                                    anchors.leftMargin: 10
                                    spacing: 10
                                    visible: !modelData.header

                                    MaterialIcon {
                                        icon: modelData.icon ?? ""
                                        color: selected ? Appearance.colors.m3on_primary : Appearance.colors.m3on_surface
                                        font.pixelSize: 24
                                        Behavior on color { ColorAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic }}
                                    }

                                    Text {
                                        text: modelData.label ?? ""
                                        font.pixelSize: 16
                                        color: selected ? Appearance.colors.m3on_primary : Appearance.colors.m3on_surface
                                        Behavior on color { ColorAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic }}
                                    }
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: modelData.page !== -1
                                    onClicked: {
                                        if (modelData.page !== -1) {
                                            root.selectedIndex = modelData.page
                                            settingsStack.currentIndex = modelData.page
                                        }
                                    }
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
                    anchors.left: sidebarBG.right
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    // Connections
                    WifiMenu {}
                    BluetoothMenu {}
                    VPNMenu {}
                    // System
                    SoundsMenu {}
                    PowerMenu {}
                    // Customization
                    WallpaperMenu {}
                    ColorsMenu {}
                    BarMenu {}
                    AboutMenu {}
                }
            }
        }
    }
}
