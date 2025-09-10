pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root
    signal workspaceUpdated()
    signal rawEvent(var event)

    // this is really just a helper object for `focusedWorkspace` lmfaoo
    readonly property QtObject currentWorkspace: QtObject {
        property bool hasWindow: root.focusedWorkspace.toplevels?.values.length !== 0

        function hasTilingWindow() {
            let result = false

            if (root.focusedWorkspace && root.focusedWorkspace.toplevels) {
                for (let toplevel of root.focusedWorkspace.toplevels.values) {
                    if (!toplevel.lastIpcObject?.floating) {
                        result = true
                        break
                    }
                }
            }
            return result
        }
    }

    readonly property var toplevels: Hyprland.toplevels
    readonly property var workspaces: Hyprland.workspaces
    readonly property var monitors: Hyprland.monitors
    readonly property HyprlandToplevel activeToplevel: Hyprland.activeToplevel
    readonly property HyprlandWorkspace focusedWorkspace: Hyprland.focusedWorkspace
    readonly property HyprlandMonitor focusedMonitor: Hyprland.focusedMonitor
    readonly property int activeWsId: focusedWorkspace?.id ?? 1

    function dispatch(request: string): void {
        Hyprland.dispatch(request);
    }

    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            root.rawEvent(event);
            const n = event.name;
            if (!n.endsWith("v2")) {
                if (["workspace", "moveworkspace", "activespecial", "focusedmon"].includes(n)) {
                    Hyprland.refreshWorkspaces();
                    Hyprland.refreshMonitors();
                } else if (["openwindow", "closewindow", "movewindow"].includes(n)) {
                    Hyprland.refreshToplevels();
                    Hyprland.refreshWorkspaces();
                } else if (n.includes("mon")) {
                    Hyprland.refreshMonitors();
                } else if (n.includes("workspace")) {
                    Hyprland.refreshWorkspaces();
                } else if (n.includes("window") || n.includes("group") || ["pin", "fullscreen", "changefloatingmode", "minimize"].includes(n)) {
                    Hyprland.refreshToplevels();
                }
            }
            root.workspaceUpdated(); 

        }
    }

}