import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window

import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland as Hypr

import qs.whisker.modules
import qs.whisker.modules.corners
import qs.whisker.components.misc
import qs.whisker.components
import qs.whisker.services

// menus
import qs.whisker.windows.settings.menus.about
import qs.whisker.windows.settings.menus.bar
import qs.whisker.windows.settings.menus.bluetooth
import qs.whisker.windows.settings.menus.colors
import qs.whisker.windows.settings.menus.misc
import qs.whisker.windows.settings.menus.network
import qs.whisker.windows.settings.menus.power
import qs.whisker.windows.settings.menus.sounds
import qs.whisker.windows.settings.menus.system
import qs.whisker.windows.settings.menus.user
import qs.whisker.windows.settings.menus.vpn
import qs.whisker.windows.settings.menus.wallpaper
import qs.whisker.windows.settings.menus.widgets

import qs.whisker.windows.settings.components

Scope {
    id: root

    property var screen: null

    SettingsData {
        id: settingsData
        screen: root.screen
    }

    property string selectedMenu: "network"
    readonly property var selectedItem: {
        for (const menu of settingsData.menus) {
            for (const item of menu.items) {
                if (item.id === root.selectedMenu)
                    return item
            }
        }
        return null
    }

    property int sidebarWidth: 360

    property bool opened: false

    IpcHandler {
        target: "settings"

        function open(menu: string) {
            root.opened = true

            const target = (menu ?? "").trim().toLowerCase()
            if (target === "") return

            for (const section of settingsData.menus) {
                for (const item of section.items) {
                    if (
                        String(item.id ?? "").toLowerCase() === target
                        || String(item.label ?? "").toLowerCase() === target
                    ) {
                        root.selectedMenu = item.id
                        return
                    }
                }
            }
        }
    }
    
    CustomShortcut {
        name: "settings"
        description: "Open Whisker settings."

        onReleased: () => {
            root.opened = !root.opened;
        }
    }

    LazyLoader {
        active: root.opened
        Window {
            id: win

            width: 1280
            height: 720
            visible: true
            title: "Whisker Settings"
            color: Appearance.colors.m3background
            onClosing: root.opened = false

            Component.onCompleted: {
                Log.info('windows/settings/Settings.qml', 'setting root.screen to ' + win.screen)
                root.screen = win.screen
            }

            /// visual objects ///
            Item {
                id: container
                anchors.fill: parent

                ColumnLayout {
                    id: containerLayout
                    anchors.fill: parent
                    spacing: 0

                    StyledRectangle {
                        id: titleBar

                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        Layout.minimumHeight: 40
                        Layout.maximumHeight: 40

                        MaterialIcon {
                            id: titleIcon
                            anchors {
                                left: parent.left
                                leftMargin: 15
                                verticalCenter: parent.verticalCenter
                            }
                            icon: root.selectedItem ? root.selectedItem.icon : "pets"
                            size: 20
                            color: Appearance.colors.m3secondary
                        }

                        RowLayout {
                            anchors.centerIn: parent

                            StyledText {
                                text: win.title.replace("Whisker ", "")
                                font.family: "Outfit SemiBold"
                                font.pixelSize: 20
                            }

                            StyledText {
                                visible: (root.selectedItem.label ?? "") !== ""
                                text: "•"
                                font.family: "Outfit SemiBold"
                                font.pixelSize: 20
                                color: Appearance.colors.m3on_surface_variant
                            }

                            StyledText {
                                text: root.selectedItem.label ?? ""
                                font.pixelSize: 16
                                color: Appearance.colors.m3on_surface_variant
                            }
                        }

                        StyledButton {
                            anchors {
                                right: parent.right
                                rightMargin: 10
                                verticalCenter: parent.verticalCenter
                            }
                            width: 32
                            height: 32
                            icon: "close"
                            base_fg: Appearance.colors.m3on_surface
                            base_bg: Appearance.colors.m3surface
                            onClicked: { win.close() }
                        }
                    }

                    RowLayout {
                        id: contentLayout

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 0

                        Item {
                            id: sidebarArea

                            Layout.preferredWidth: root.sidebarWidth
                            Layout.maximumWidth: root.sidebarWidth
                            Layout.fillHeight: true

                            ColumnLayout {
                                id: sidebarLayout

                                anchors {
                                    top: parent.top
                                    topMargin: 10
                                    left: parent.left
                                    leftMargin: 20
                                    bottom: parent.bottom
                                    bottomMargin: 10
                                }
                                width: parent.width - 40
                                spacing: 10

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    StyledButton {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 48
                                        icon: "edit"
                                        text: "Config file"
                                        // bottomRightRadius: 5
                                        // topRightRadius: 5
                                        secondary: true

                                        onClicked: {
                                            Quickshell.execDetached({
                                                command: [
                                                    "xdg-open",
                                                    Quickshell.env("HOME") + "/.config/whisker/preferences.json"
                                                ]
                                            })
                                        }
                                    }

                                    // StyledButton {
                                    //     Layout.preferredHeight: 48
                                    //     Layout.preferredWidth: 34
                                    //     icon: root.sidebarCollapsed ? "chevron_right" : "chevron_left"
                                    //     bottomLeftRadius: 5
                                    //     topLeftRadius: 5
                                    //     secondary: true

                                    //     onClicked: root.sidebarCollapsed = !root.sidebarCollapsed
                                    // }
                                }

                                ListView {
                                    id: sidebarList
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 10
                                    clip: true
                                    model: settingsData.menus
                                    delegate: SidebarItem {
                                        selectedItem: root.selectedMenu
                                        width: ListView.view.width

                                        onItemSelected: itemId => root.selectedMenu = itemId
                                    }
                                }
                            }
                        }

                        StyledRectangle {
                            id: contentMenuArea
                            color: Appearance.colors.m3surface_container_low
                            radius: Appearance.rounding.large

                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.bottomMargin: 10
                            Layout.rightMargin: 10

                            Loader {
                                anchors.fill: parent
                                anchors.margins: 20
                                sourceComponent: root.selectedItem
                                    ? root.selectedItem.component
                                    : settingsData.fallbackComponent
                            }
                        }
                    }
                }
            }

        }
    }

}
