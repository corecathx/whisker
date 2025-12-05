import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.services
import qs.modules
import qs.preferences

Item {
    id: root
    property int maxWidth: screen.width * 0.8
    property int cardSize: {
        var cols = Preferences.verticalBar() ? 1 : 4;
        var spacing = 10 * (cols - 1);
        return Math.min(300, (maxWidth - spacing) / cols);
    }

    implicitWidth: Math.min(maxWidth, container.implicitWidth)
    implicitHeight: container.implicitHeight + 10
    property int dragSourceWorkspace: -1
    property int dragTargetWorkspace: -1

    GridLayout {
        id: container
        anchors.centerIn: parent
        rows: Preferences.verticalBar() ? 1 : 4
        columns: Preferences.verticalBar() ? 1 : 4
        rowSpacing: 10
        columnSpacing: 10

        Repeater {
            model: Hyprland.fullWorkspaces
            delegate: Item {
                id: workspaceItem
                property real usableWidth: screen.width - (Preferences.verticalBar() ? Appearance.barSize : 0)
                property real usableHeight: screen.height - (Preferences.horizontalBar() ? Appearance.barSize : 0)
                property int workspaceId: model.id
                property bool isDragSource: root.dragSourceWorkspace === workspaceId
                z: isDragSource ? 100 : 0
                Layout.preferredWidth: root.cardSize
                Layout.preferredHeight: root.cardSize * (usableHeight / usableWidth)
                MouseArea {
                    anchors.fill: parent
                    enabled: workspaceCard.safeToplevels.values.length === 0
                    onClicked: {
                        Hyprland.dispatch('workspace ' + workspaceItem.workspaceId);
                    }
                    cursorShape: Qt.PointingHandCursor
                }
                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "transparent"
                    border.color: Appearance.colors.m3primary
                    border.width: focused ? 1 : 0

                    Behavior on border.width {
                        NumberAnimation {
                            duration: Appearance.animation.fast
                            easing.type: Appearance.animation.easing
                        }
                    }
                }
                Rectangle {
                    id: workspaceCard
                    anchors.fill: parent
                    anchors.margins: focused ? 2 : 0
                    radius: 10
                    clip: !workspaceItem.isDragSource
                    color: focused ? Appearance.colors.m3surface_container_high : Appearance.colors.m3surface_container

                    Behavior on anchors.margins {
                        NumberAnimation {
                            duration: Appearance.animation.fast
                            easing.type: Appearance.animation.easing
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Appearance.animation.fast
                            easing.type: Appearance.animation.easing
                        }
                    }

                    StyledText {
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

                    property real scaleX: width / workspaceItem.usableWidth
                    property real scaleY: height / workspaceItem.usableHeight

                    Repeater {
                        model: workspaceCard.safeToplevels
                        delegate: Item {
                            id: windowPreview
                            property var win: modelData && modelData.lastIpcObject ? modelData.lastIpcObject : null
                            property bool hasValidGeometry: win && win.at && win.size
                            property bool isFloating: win && win.floating

                            visible: hasValidGeometry

                            property real offsetX: Preferences.verticalBar() ? Appearance.barSize : 0
                            property real offsetY: Preferences.horizontalBar() ? Appearance.barSize : 0

                            property real initX: hasValidGeometry ? (win.at[0] - offsetX) * workspaceCard.scaleX : 0
                            property real initY: hasValidGeometry ? (win.at[1] - offsetY) * workspaceCard.scaleY : 0

                            x: initX
                            y: initY
                            width: hasValidGeometry ? win.size[0] * workspaceCard.scaleX : 0
                            height: hasValidGeometry ? win.size[1] * workspaceCard.scaleY : 0

                            z: windowMouseArea.drag.active
                                ? 1000
                                : (isFloating ? 100 : 0)

                            Drag.active: windowMouseArea.drag.active
                            Drag.source: windowPreview
                            Drag.hotSpot.x: width / 2
                            Drag.hotSpot.y: height / 2

                            Rectangle {
                                id: previewContainer
                                anchors.fill: parent
                                color: "transparent"
                                radius: 5
                                clip: true

                                ScreencopyView {
                                    id: preview
                                    anchors.fill: parent
                                    captureSource: modelData && modelData.wayland ? modelData.wayland : null
                                    live: Preferences.misc.renderOverviewWindows && visible
                                    visible: Preferences.misc.renderOverviewWindows && captureSource !== null

                                    layer.enabled: windowMouseArea.containsMouse
                                    layer.effect: MultiEffect {
                                        blurEnabled: true
                                        blur: 1.0
                                        blurMax: 16
                                    }
                                }

                                Rectangle {
                                    id: darker
                                    anchors.fill: parent
                                    color: Appearance.colors.m3surface
                                    opacity: windowMouseArea.containsMouse ? 0.4 : 0.2
                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: Appearance.animation.fast
                                            easing.type: Appearance.animation.easing
                                        }
                                    }
                                }

                                Rectangle {
                                    width: windowMouseArea.containsMouse ? 60 : 50
                                    height: windowMouseArea.containsMouse ? 60 : 50
                                    color: Appearance.colors.m3surface
                                    radius: 20
                                    anchors.centerIn: parent

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: Appearance.animation.fast
                                            easing.type: Appearance.animation.easing
                                        }
                                    }
                                    Behavior on height {
                                        NumberAnimation {
                                            duration: Appearance.animation.fast
                                            easing.type: Appearance.animation.easing
                                        }
                                    }

                                    IconImage {
                                        source: Utils.getAppIcon(windowPreview.win.class ?? "")
                                        width: windowMouseArea.containsMouse ? 35 : 30
                                        height: windowMouseArea.containsMouse ? 35 : 30
                                        anchors.centerIn: parent

                                        Behavior on width {
                                            NumberAnimation {
                                                duration: Appearance.animation.fast
                                                easing.type: Appearance.animation.easing
                                            }
                                        }
                                        Behavior on height {
                                            NumberAnimation {
                                                duration: Appearance.animation.fast
                                                easing.type: Appearance.animation.easing
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 5
                                    color: "transparent"
                                    border.color: Appearance.colors.m3primary
                                    border.width: windowMouseArea.containsMouse ? 2 : 0
                                    opacity: 0.6

                                    Behavior on border.width {
                                        NumberAnimation {
                                            duration: Appearance.animation.fast
                                            easing.type: Appearance.animation.easing
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: windowMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                                drag.target: windowPreview

                                property real pressX
                                property real pressY
                                property bool dragging: false

                                onPressed: function (mouse) {
                                    pressX = mouse.x;
                                    pressY = mouse.y;
                                    dragging = false;
                                    root.dragSourceWorkspace = workspaceItem.workspaceId;
                                }

                                onPositionChanged: function (mouse) {
                                    if (!dragging && (Math.abs(mouse.x - pressX) > 5 || Math.abs(mouse.y - pressY) > 5)) {
                                        dragging = true;
                                    }
                                }

                                onReleased: function (mouse) {
                                    if (!dragging) {
                                        Hyprland.dispatch('workspace ' + workspaceCard.workspace.id);
                                    } else {
                                        var targetWorkspace = root.dragTargetWorkspace;

                                        if (targetWorkspace !== -1 && targetWorkspace !== root.dragSourceWorkspace) {
                                            Hyprland.dispatch('movetoworkspacesilent ' + targetWorkspace + ',address:' + windowPreview.win.address);
                                        } else if (targetWorkspace === root.dragSourceWorkspace) {
                                            if (windowPreview.isFloating) {
                                                var centerX = windowPreview.x + windowPreview.width / 2;
                                                var centerY = windowPreview.y + windowPreview.height / 2;

                                                var dropX = (centerX / workspaceCard.scaleX) - (windowPreview.win.size[0] / 2) + windowPreview.offsetX;
                                                var dropY = (centerY / workspaceCard.scaleY) - (windowPreview.win.size[1] / 2) + windowPreview.offsetY;

                                                Hyprland.dispatch('movewindowpixel exact ' + Math.round(dropX) + ' ' + Math.round(dropY) + ',address:' + windowPreview.win.address);
                                            } else {
                                                var relX = (windowPreview.x + windowPreview.width / 2) / workspaceCard.width;
                                                var relY = (windowPreview.y + windowPreview.height / 2) / workspaceCard.height;
                                                var direction = "";
                                                if (relX < 0.25)
                                                    direction = "l";
                                                else if (relX > 0.75)
                                                    direction = "r";
                                                else if (relY < 0.25)
                                                    direction = "u";
                                                else if (relY > 0.75)
                                                    direction = "d";

                                                if (direction && (Math.abs(windowPreview.x - windowPreview.initX) > 10 || Math.abs(windowPreview.y - windowPreview.initY) > 10))
                                                    Hyprland.dispatch('movewindow ' + direction + ',address:' + windowPreview.win.address);
                                            }
                                        }

                                        // windowPreview.x = windowPreview.initX;
                                        // windowPreview.y = windowPreview.initY;
                                        root.dragSourceWorkspace = -1;
                                        root.dragTargetWorkspace = -1;
                                    }
                                }
                            }
                        }
                    }

                    // drop area highlight
                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: Appearance.colors.m3primary
                        opacity: workspaceDropArea.containsDrag ? 0.15 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Appearance.animation.fast
                                easing.type: Appearance.animation.easing
                            }
                        }
                    }

                    DropArea {
                        id: workspaceDropArea
                        anchors.fill: parent

                        onEntered: function (drag) {
                            root.dragTargetWorkspace = workspaceItem.workspaceId;
                        }

                        onExited: function (drag) {
                            if (root.dragTargetWorkspace === workspaceItem.workspaceId)
                                root.dragTargetWorkspace = -1;
                        }
                    }
                }
            }
        }
    }
}
