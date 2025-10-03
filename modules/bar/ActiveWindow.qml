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
    
    MouseArea {
        id: detect
        anchors.fill: parent
        hoverEnabled: true
        
        StyledPopout {
            hoverTarget: !Hyprland.currentWorkspace.hasWindow ? null : detect
            interactable: true
            RowLayout {
                spacing: 10
                IconImage {
                    implicitWidth: 25
                    implicitHeight: 25
                    source: {
                        return Utils.getAppIcon(
                            Hyprland.activeToplevel?.lastIpcObject.class ?? ""
                        )
                    }
                }
                Text {
                    text: {
                        return Utils.truncateText(
                            Hyprland.activeToplevel?.lastIpcObject.title ?? "",
                            40
                        )
                    }
                    font.pixelSize: 14
                    color: Appearance.colors.m3on_surface
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                }
            }
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
                            let calculatedHeight = 400 * preview.sourceSize.height / preview.sourceSize.width
                            return Math.min(calculatedHeight, 400)
                        }
                        return 400
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
            RowLayout {
                Rectangle {
                    implicitWidth: 30
                    implicitHeight: implicitWidth
                    radius: 10
                    color: Appearance.colors.m3surface_container

                    MaterialIcon {
                        icon: 'visibility'
                        font.pixelSize: 20
                        color: Appearance.colors.m3on_surface
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        id: hoverListener
                        anchors.fill: parent
                        
                        hoverEnabled: true
                        StyledPopout {
                            hoverTarget: hoverListener

                            Text {
                                text: "Hidden: " + Hyprland.activeToplevel.lastIpcObject.visibility
                                color: Appearance.colors.m3on_surface
                            }
                        }
                    }
                }
            }
        }
    }
}