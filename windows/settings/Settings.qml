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
        function open(menu: string) {
            Globals.visible_settingsMenu = true;
            if (menu !== "" && settingsWindow !== null) {
                for (var i = 0; i < settingsWindow.menuModel.length; i++) {
                    var item = settingsWindow.menuModel[i];
                    if (!item.header && item.label.toLowerCase() === menu.toLowerCase()) {
                        settingsWindow.selectedIndex = item.page;
                        break;
                    }
                }
            }
        }
    }

    LazyLoader {
        active: Globals.visible_settingsMenu
        Window {
            id: root
            property int selectedIndex: 0
            property bool sidebarCollapsed: false
            width: 1280
            height: 720
            visible: true
            title: "Whisker Settings"
            color: Appearance.colors.m3background
            onClosing: Globals.visible_settingsMenu = false

            property var menuModel: {
                var raw = [
                    { header: true, label: "Connections" },
                    { icon: "language", label: "Network", component: "NetworkMenu" },
                    { icon: "bluetooth", label: "Bluetooth", component: "BluetoothMenu" },
                    { icon: "vpn_key", label: "VPN", component: "VPNMenu" },
                    { header: true, label: "System" },
                    { icon: "volume_up", label: "Sounds", component: "SoundsMenu" },
                    { icon: "power", label: "Power", component: "PowerMenu" },
                    { header: true, label: "Customization" },
                    { icon: "wallpaper", label: "Wallpaper", component: "WallpaperMenu" },
                    { icon: "palette", label: "Colors", component: "ColorsMenu" },
                    { icon: "horizontal_rule", label: "Bar", component: "BarMenu" },
                    { icon: "widgets", label: "Widgets", component: "WidgetsMenu" },
                    // { icon: "tune", label: "Misc", component: "MiscMenu" },
                    { header: true, label: "About" },
                    { icon: "info", label: "System", component: "SystemMenu" },
                    { icon: "help", label: "About", component: "AboutMenu" }
                ];
                var pageCounter = 0;
                return raw.map(function (item) {
                    item.page = item.header ? -1 : pageCounter++;
                    return item;
                });
            }

            Component.onCompleted: { settingsWindow = root; }

            Item {
                anchors.fill: parent

                Rectangle {
                    id: sidebarBG
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: root.sidebarCollapsed ? 70 : 320
                    color: Appearance.colors.m3surface_container_low
                    Behavior on width { NumberAnimation { duration: Appearance.animation.normal; easing.type: Appearance.animation.easing } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: root.sidebarCollapsed ? 8 : 32
                        anchors.rightMargin: root.sidebarCollapsed ? 8 : 32
                        anchors.topMargin: 32
                        anchors.bottomMargin: 32
                        spacing: 4
                        Behavior on anchors.leftMargin { NumberAnimation { duration: Appearance.animation.normal; easing.type: Appearance.animation.easing } }
                        Behavior on anchors.rightMargin { NumberAnimation { duration: Appearance.animation.normal; easing.type: Appearance.animation.easing } }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 8
                            StyledText {
                                Layout.fillWidth: true
                                text: "Settings"
                                color: Appearance.colors.m3on_surface
                                font.family: "Outfit ExtraBold"
                                font.pixelSize: 24
                                visible: !root.sidebarCollapsed
                                opacity: root.sidebarCollapsed ? 0 : 1
                                Behavior on opacity { NumberAnimation { duration: Appearance.animation.fast } }
                            }
                            StyledButton {
                                Layout.preferredHeight: 34
                                Layout.preferredWidth: 34
                                Layout.alignment: Qt.AlignHCenter
                                icon: root.sidebarCollapsed ? "chevron_right" : "chevron_left"
                                secondary: true
                                onClicked: root.sidebarCollapsed = !root.sidebarCollapsed
                            }
                        }

                        BaseCard {
                            id: userCard
                            Layout.fillWidth: true
                            cardMargin: 8
                            useAnims: false
                            cardSpacing: 0
                            verticalPadding: 16
                            property bool opened: false
                            visible: !root.sidebarCollapsed
                            opacity: root.sidebarCollapsed ? 0 : 1
                            Behavior on opacity { NumberAnimation { duration: Appearance.animation.fast } }
                            property bool hovered: mouseArea.containsMouse
                            color: hovered ? Appearance.colors.m3surface_container_high : Appearance.colors.m3surface_container

                            RowLayout {
                                width: parent.width
                                spacing: 8
                                ClippingRectangle {
                                    radius: 100
                                    color: "transparent"
                                    Layout.preferredWidth: userCard.opened ? 50 : 36
                                    Layout.preferredHeight: userCard.opened ? 50 : 36
                                    Behavior on Layout.preferredWidth { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
                                    Behavior on Layout.preferredHeight { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
                                    IconImage { anchors.fill: parent; source: Appearance.profileImage }
                                }
                                ColumnLayout {
                                    spacing: 2
                                    StyledText {
                                        text: Quickshell.env("USER")
                                        color: Appearance.colors.m3on_surface
                                        font.pixelSize: 19
                                        font.family: "Outfit SemiBold"
                                    }
                                    RowLayout {
                                        visible: userCard.opened
                                        Image { sourceSize: Qt.size(18, 18); source: Quickshell.iconPath(System.logo) }
                                        StyledText { text: System.prettyName; color: Colors.opacify(Appearance.colors.m3on_surface, 0.7); font.pixelSize: 11 }
                                    }
                                }
                            }
                            MouseArea { id: mouseArea; anchors.fill: parent; hoverEnabled: true; onClicked: userCard.opened = !userCard.opened }
                        }

                        ListView {
                            id: sidebarList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: root.menuModel
                            spacing: 4
                            boundsBehavior: Flickable.StopAtBounds
                            delegate: Item {
                                width: sidebarList.width
                                height: modelData.header ? (root.sidebarCollapsed ? 0 : 26) : 36
                                property bool hovered: mouseArea2.containsMouse
                                property bool selected: root.selectedIndex === modelData.page && modelData.page !== -1
                                visible: !modelData.header || !root.sidebarCollapsed

                                Item {
                                    width: parent.width
                                    height: parent.height
                                    visible: modelData.header ?? false
                                    StyledText { y: (parent.height - height) * 0.5; x: 8; text: modelData.label; font.pixelSize: 13; font.bold: true; color: Colors.opacify(Appearance.colors.m3on_surface, 0.6) }
                                }
                                Rectangle {
                                    id: sidebarItemBG
                                    anchors.fill: parent
                                    visible: !modelData.header
                                    color: selected ? Appearance.colors.m3primary : (hovered ? Appearance.colors.m3surface_container_high : Appearance.colors.m3surface_container_low)
                                    radius: 18
                                    Behavior on color { ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
                                    RowLayout {
                                        y: (parent.height - height) * 0.5
                                        x: root.sidebarCollapsed ? (parent.width - width) * 0.5 : 8
                                        spacing: 8
                                        MaterialIcon {
                                            icon: modelData.icon ?? ""
                                            color: selected ? Appearance.colors.m3on_primary : Appearance.colors.m3on_surface
                                            font.pixelSize: 22
                                            Behavior on color { ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
                                        }
                                        StyledText {
                                            text: modelData.label ?? ""
                                            font.pixelSize: 15
                                            color: selected ? Appearance.colors.m3on_primary : Appearance.colors.m3on_surface
                                            visible: !root.sidebarCollapsed
                                            opacity: root.sidebarCollapsed ? 0 : 1
                                            Behavior on color { ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
                                            Behavior on opacity { NumberAnimation { duration: Appearance.animation.fast } }
                                        }
                                    }
                                }
                                MouseArea { id: mouseArea2; anchors.fill: parent; hoverEnabled: true; enabled: modelData.page !== -1; onClicked: { if (modelData.page !== -1) root.selectedIndex = modelData.page; } }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 18
                            visible: !root.sidebarCollapsed
                            StyledText { x: (parent.width - width) * 0.5; text: "! Everything here is TBA !"; color: Colors.opacify(Appearance.colors.m3on_surface_variant, 0.6); font.pixelSize: 11 }
                        }
                    }
                }


                Item {
                    id: settingsContainer
                    anchors.left: sidebarBG.right
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    Loader {
                        id: menuLoader
                        anchors.fill: parent
                        sourceComponent: {
                            var components = {
                                NetworkMenu: networkComponent, BluetoothMenu: bluetoothComponent, VPNMenu: vpnComponent,
                                SoundsMenu: soundsComponent, PowerMenu: powerComponent, WallpaperMenu: wallpaperComponent,
                                ColorsMenu: colorsComponent, BarMenu: barComponent, WidgetsMenu: widgetsComponent,
                                MiscMenu: miscComponent, SystemMenu: systemComponent, AboutMenu: aboutComponent
                            };
                            var currentMenu = null;
                            for (var i = 0; i < root.menuModel.length; i++) {
                                if (root.menuModel[i].page === root.selectedIndex) {
                                    currentMenu = root.menuModel[i];
                                    break;
                                }
                            }
                            var menuName = currentMenu?.component ?? "";
                            return components[menuName] || fallbackComponent;
                        }
                    }
                }
            }

            // networks
            Component { id: networkComponent; NetworkMenu {} }
            Component { id: bluetoothComponent; BluetoothMenu {} }
            Component { id: vpnComponent; VPNMenu {} }
            // system
            Component { id: soundsComponent; SoundsMenu {} }
            Component { id: powerComponent; PowerMenu {} }
            // customization
            Component { id: wallpaperComponent; WallpaperMenu { screen: root.screen } }
            Component { id: colorsComponent; ColorsMenu {} }
            Component { id: barComponent; BarMenu {} }
            Component { id: widgetsComponent; WidgetsMenu {} }
            Component { id: miscComponent; MiscMenu {} }
            // about
            Component { id: systemComponent; SystemMenu {} }
            Component { id: aboutComponent; AboutMenu {} }
            // fallback just in case i forgot to add a menu...
            Component { id: fallbackComponent; FallbackMenu {} }
        }
    }

    property var settingsWindow: null
}
