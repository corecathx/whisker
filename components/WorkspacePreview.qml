import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.services
import qs.modules
import qs.preferences

Item {
    id: root
    implicitWidth: Math.min(screen.width * 0.8, container.implicitWidth)
    implicitHeight: container.implicitHeight + 10
    
    GridLayout {
        id: container
        anchors.centerIn: parent
        rows: Preferences.verticalBar() ? 1 : 4
        columns: Preferences.verticalBar() ? 1 : 4
        rowSpacing: 8
        columnSpacing: 8
        
        Repeater {
            model: Hyprland.fullWorkspaces
            delegate: Item {
                Layout.preferredWidth: 300
                Layout.preferredHeight: 300 * (screen.height / screen.width)
                
                ClippingRectangle {
                    id: workspaceCard
                    anchors.fill: parent
                    anchors.margins: focused ? 2 : 0
                    radius: 10
                    clip: true
                    color: focused ? Appearance.colors.m3surface_container_high : Appearance.colors.m3surface_container
                    
                    Behavior on anchors.margins {
                        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                    }

                                        
                    Text {
                        anchors.centerIn: parent
                        text: model.id
                        color: Appearance.colors.m3on_surface
                        font.pixelSize: 20
                        font.bold: true
                        visible: workspaceCard.safeToplevels.values.length === 0
                    }
                    
                    property var workspace: {
                        if (!model.hasWorkspace || model.workspaceId < 0)
                            return null;
                        return Hyprland.getWorkspace(model.workspaceId);
                    }
                    
                    property var safeToplevels: {
                        if (!workspace || !workspace.toplevels)
                            return [];
                        return workspace.toplevels;
                    }
                    
                    property real scaleX: width / screen.width
                    property real scaleY: height / screen.height
                    
                    Repeater {
                        model: workspaceCard.safeToplevels
                        delegate: ClippingRectangle {
                            property var win: modelData && modelData.lastIpcObject ? modelData.lastIpcObject : null
                            property bool hasValidGeometry: win && win.at && win.size
                            
                            visible: hasValidGeometry
                            color: "transparent"
                            
                            x: hasValidGeometry ? win.at[0] * workspaceCard.scaleX : 0
                            y: hasValidGeometry ? win.at[1] * workspaceCard.scaleY : 0
                            width: hasValidGeometry ? win.size[0] * workspaceCard.scaleX : 0
                            height: hasValidGeometry ? win.size[1] * workspaceCard.scaleY : 0
                            
                            ScreencopyView {
                                id: preview
                                anchors.fill: parent
                                captureSource: modelData && modelData.wayland ? modelData.wayland : null
                                live: false
                                visible: captureSource !== null
                            }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch('workspace ' + model.id)
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                
                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "transparent"
                    border.color: Appearance.colors.m3primary
                    border.width: focused ? 1 : 0
                    
                    Behavior on border.width { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }
            }
        }
    }
}