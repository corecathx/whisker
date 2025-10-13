import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.services
import qs.modules
import qs.components

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
                    return "file://" + Quickshell.shellDir + "/logo.png";
                }
                return Utils.getAppIcon(Hyprland.activeToplevel?.lastIpcObject.class ?? "");
            }
            implicitWidth: 20
            implicitHeight: 20
        }

        ColumnLayout {
            spacing: -4

            StyledText {
                text: {
                    if (!Hyprland.currentWorkspace.hasWindow) {
                        return "Desktop";
                    }
                    return Utils.truncateText(Hyprland.activeToplevel?.lastIpcObject.class, 30);
                }
                font.pixelSize: 10
                color: Appearance.colors.m3on_surface
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
            }

            StyledText {
                text: {
                    if (!Hyprland.currentWorkspace.hasWindow) {
                        return "Workspace " + Hyprland.activeWsId;
                    }
                    return Utils.truncateText(Hyprland.activeToplevel?.lastIpcObject.title ?? "", 35);
                }
                font.pixelSize: 12
                font.family: "Outfit Medium"
                color: Appearance.colors.m3on_surface
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
            }
        }
    }

    HoverHandler {
        id: detect
    }
    StyledPopout {
        hoverTarget: !Hyprland.currentWorkspace.hasWindow ? null : detect
        interactable: true
        Component {
            RowLayout {
                spacing: 10
                IconImage {
                    implicitWidth: 25
                    implicitHeight: 25
                    source: {
                        return Utils.getAppIcon(Hyprland.activeToplevel?.lastIpcObject.class ?? "");
                    }
                }
                StyledText {
                    text: {
                        return Utils.truncateText(Hyprland.activeToplevel?.lastIpcObject.title ?? "", 40);
                    }
                    font.pixelSize: 14
                    color: Appearance.colors.m3on_surface
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                }
            }
        }

        Component {
            ClippingRectangle {
                implicitWidth: 400
                implicitHeight: previewContainer.implicitHeight
                radius: 10
                color: Appearance.colors.m3surface_container

                Item {
                    id: previewContainer
                    anchors.fill: parent
                    implicitWidth: 400
                    implicitHeight: {
                        if (preview.sourceSize.width > 0 && preview.sourceSize.height > 0) {
                            let calculatedHeight = 400 * preview.sourceSize.height / preview.sourceSize.width;
                            return Math.min(calculatedHeight, 400);
                        }
                        return 400;
                    }

                    ScreencopyView {
                        id: preview
                        anchors.fill: parent
                        anchors.margins: 2
                        captureSource: ToplevelManager.activeToplevel
                        live: true
                    }
                }
            }
        }
    }
}
