pragma Singleton
import QtQuick 2.15
import Quickshell
QtObject {
    property real panel_opacity: 1
    property color panel_color: Colors.opacify(Colors.background, panel_opacity)
    property string wallpaper: "file://"+Colors.wallpaper
    property string profileImage: "file://"+"/home/" + Quickshell.env("USER") + "/.face"
    property string whiskerIcon: "file://"+"/home/" + Quickshell.env("USER") + "/.config/quickshell/logo.png"
}
