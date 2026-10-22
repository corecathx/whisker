import QtQuick

import qs.windows.settings.menus.about
import qs.windows.settings.menus.bar
import qs.windows.settings.menus.bluetooth
import qs.windows.settings.menus.colors
import qs.windows.settings.menus.misc
import qs.windows.settings.menus.network
import qs.windows.settings.menus.power
import qs.windows.settings.menus.sounds
import qs.windows.settings.menus.system
import qs.windows.settings.menus.user
import qs.windows.settings.menus.wallpaper
import qs.windows.settings.menus.widgets

QtObject {
    id: root

    property var screen

    readonly property var menus: [
        {
            title: "Connections",
            items: [
                { id: "network", label: "Network", description: "Wi-Fi and Ethernet", icon: "language", component: networkComponent },
                { id: "bluetooth", label: "Bluetooth", description: "Bluetooth devices and connections", icon: "bluetooth", component: bluetoothComponent }
            ]
        },
        {
            title: "System",
            items: [
                { id: "sounds", label: "Sound", description: "Volume and audio devices", icon: "volume_up", component: soundsComponent },
                { id: "power", label: "Power", description: "Power profiles and battery", icon: "power", component: powerComponent }
            ]
        },
        {
            title: "Customization",
            items: [
                { id: "wallpaper", label: "Wallpaper", description: "Wallpaper and background", icon: "wallpaper", component: wallpaperComponent },
                { id: "colors", label: "Colors", description: "Color scheme and theme", icon: "palette", component: colorsComponent },
                { id: "bar", label: "Bar", description: "Layout and appearance", icon: "horizontal_rule", component: barComponent },
                { id: "widgets", label: "Widgets", description: "Desktop and bar widgets", icon: "widgets", component: widgetsComponent }
            ]
        },
        {
            title: "User",
            items: [
                { id: "profile", label: "Profile", description: "Account and user preferences", icon: "account_circle", component: userComponent }
            ]
        },
        {
            title: "About",
            items: [
                { id: "system", label: "System", description: "Device information and system status", icon: "info", component: systemComponent },
                { id: "about", label: "About", description: "Whisker version and information", icon: "help", component: aboutComponent }
            ]
        }
    ]

    //// settings content component ////
    // networks
    property Component networkComponent: Component { NetworkMenu {} }
    property Component bluetoothComponent: Component { BluetoothMenu {} }
    // Component { id: vpnComponent; VPNMenu {} }

    // system
    property Component soundsComponent: Component { SoundsMenu {} }
    property Component powerComponent: Component { PowerMenu {} }

    // customization
    property Component wallpaperComponent: Component { WallpaperMenu { screen: root.screen } }
    property Component colorsComponent: Component { ColorsMenu {} }
    property Component barComponent: Component { BarMenu {} }
    property Component widgetsComponent: Component { WidgetsMenu {} }
    property Component miscComponent: Component { MiscMenu {} }

    // user
    property Component userComponent: Component { UserMenu {} }

    // about
    property Component systemComponent: Component { SystemMenu {} }
    property Component aboutComponent: Component { AboutMenu {} }

    // fallback just in case i forgot to add a menu...
    property Component fallbackComponent: Component { FallbackMenu {} }
}