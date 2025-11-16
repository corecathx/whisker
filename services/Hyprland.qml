pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    signal workspaceUpdated
    signal rawEvent(var event)

    readonly property var toplevels: Hyprland.toplevels
    readonly property var workspaces: Hyprland.workspaces
    readonly property var monitors: Hyprland.monitors
    readonly property HyprlandToplevel activeToplevel: Hyprland.activeToplevel
    readonly property HyprlandWorkspace focusedWorkspace: Hyprland.focusedWorkspace
    readonly property HyprlandMonitor focusedMonitor: Hyprland.focusedMonitor
    readonly property int activeWsId: focusedWorkspace?.id ?? 1
    readonly property int shownWorkspaces: 4
    readonly property ListModel fullWorkspaces: ListModel {}

    readonly property QtObject currentWorkspace: QtObject {
        property bool hasWindow: {
            try {
                return root.focusedWorkspace?.toplevels?.values.length !== 0;
            } catch (e) {
                return false;
            }
        }

        function hasTilingWindow() {
            try {
                if (!root.focusedWorkspace?.toplevels)
                    return false;

                for (let toplevel of root.focusedWorkspace.toplevels.values) {
                    if (toplevel && !toplevel.lastIpcObject?.floating) {
                        return true;
                    }
                }
                return false;
            } catch (e) {
                return false;
            }
        }
    }

    function monitorFor(screen: ShellScreen): HyprlandMonitor {
        return Hyprland.monitorFor(screen);
    }

    function getWorkspace(id: int): HyprlandWorkspace {
        try {
            const workspaceList = root.workspaces?.values || [];
            return workspaceList.find(ws => ws && ws.id === id) || null;
        } catch (e) {
            return null;
        }
    }

    function dispatch(request: string): void {
        Hyprland.dispatch(request);
    }
    function refreshToplevels() {
        console.log('toplevels updated');
        Hyprland.refreshToplevels();
    }
    function refreshWorkspaces() {
        const startTime = Date.now();
        try {
            const real = root.workspaces?.values || [];
            const sorted = real.slice().sort((a, b) => a.id - b.id);
            const maxCount = Math.max(root.shownWorkspaces, ...sorted.map(w => w.id));
            const data = [];

            for (let i = 1; i <= maxCount; i++) {
                const ws = sorted.find(w => w.id === i);
                data.push({
                    id: i,
                    focused: ws ? ws.focused : (root.activeWsId === i),
                    workspaceId: ws ? ws.id : -1,
                    hasWorkspace: !!ws,
                    name: ws?.name || ""
                });
            }

            if (fullWorkspaces.count !== data.length) {
                fullWorkspaces.clear();
                data.forEach(item => fullWorkspaces.append(item));
            } else {
                for (let i = 0; i < data.length; i++) {
                    fullWorkspaces.set(i, data[i]);
                }
            }

            const elapsed = ((Date.now() - startTime) / 1000).toFixed(3);
        } catch (e) {
            const elapsed = ((Date.now() - startTime) / 1000).toFixed(3);
        }
    }

    Component.onCompleted: refreshWorkspaces()

    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            try {
                const n = event.name;
                if (!n || !n.endsWith("v2"))
                    return;
                root.rawEvent(event);

                let needsRefresh = false;

                if (["workspace", "moveworkspace", "activespecial", "focusedmon"].includes(n)) {
                    Hyprland.refreshWorkspaces();
                    Hyprland.refreshMonitors();
                    needsRefresh = true;
                } else if (["openwindow", "closewindow", "movewindow"].includes(n)) {
                    Hyprland.refreshToplevels();
                    Hyprland.refreshWorkspaces();
                    needsRefresh = true;
                } else if (n.includes("mon")) {
                    Hyprland.refreshMonitors();
                } else if (n.includes("workspace")) {
                    Hyprland.refreshWorkspaces();
                    needsRefresh = true;
                } else if (n.includes("window") || n.includes("group") || ["pin", "fullscreen", "changefloatingmode", "minimize"].includes(n)) {
                    Hyprland.refreshToplevels();
                    Hyprland.refreshWorkspaces();
                    root.refreshWorkspaces();
                }
                if (needsRefresh) {
                    root.refreshWorkspaces();
                    root.workspaceUpdated();
                }
            } catch (e) {
                console.warn("Event handler error:", e);
            }
        }
    }
}
