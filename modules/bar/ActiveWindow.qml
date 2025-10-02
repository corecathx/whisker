import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.modules

Item {
    id: root
    implicitWidth: container.width
    implicitHeight: container.height

    RowLayout {
        id: container
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter

        IconImage {
            source: {
                if (!Hyprland.currentWorkspace.hasWindow) {
                    return "file://" + Quickshell.shellDir + "/logo.png"
                }
                return Utils.getAppIcon(
                    Hyprland.activeToplevel?.lastIpcObject.class ?? ""
                )
            }
            implicitWidth: 20
            implicitHeight: 20
        }

        ColumnLayout {
            spacing: -4

            Text {
                text: {
                    if (!Hyprland.currentWorkspace.hasWindow) {
                        return "Desktop"
                    }
                    return Utils.truncateText(
                        Hyprland.activeToplevel?.lastIpcObject.class,
                        30
                    )
                }
                font.pixelSize: 10
                color: Appearance.colors.m3on_surface
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
            }

            Text {
                text: {
                    if (!Hyprland.currentWorkspace.hasWindow) {
                        return "Workspace " + Hyprland.activeWsId
                    }
                    return Utils.truncateText(
                        Hyprland.activeToplevel?.lastIpcObject.title ?? "",
                        35
                    )
                }
                font.pixelSize: 12
                font.family: "Outfit Medium"
                color: Appearance.colors.m3on_surface
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
            }
        }
    }
}
