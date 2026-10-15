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
    readonly property HyprlandWorkspace focusedWorkspace: Hyprland.focusedWorkspace ?? undefined
    readonly property HyprlandMonitor focusedMonitor: Hyprland.focusedMonitor
    readonly property int activeWsId: focusedWorkspace?.id ?? 1
    readonly property int shownWorkspaces: 4
    property ListModel fullWorkspaces: ListModel {}

    readonly property QtObject currentWorkspace: QtObject {
        property bool hasWindow: (root.focusedWorkspace?.toplevels?.values?.length ?? 0) > 0

        function hasTilingWindow(): bool {
            try {
                const toplevels = root.focusedWorkspace?.toplevels?.values ?? [];

                return toplevels.some(toplevel =>
                    toplevel?.lastIpcObject && !toplevel.lastIpcObject.floating
                );
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
    function getToplevelFromClass(className: string): HyprlandToplevel {
        for (const toplevel of root.toplevels?.values ?? [])
            if (toplevel?.lastIpcObject?.class === className)
                return toplevel;

        return null;
    }

    function classIsRunning(className: string): bool {
        return root.getToplevelFromClass(className) !== null;
    }

    function focusToClass(className: string): bool {
        for (const toplevel of root.toplevels?.values ?? []) {
            if (toplevel?.lastIpcObject?.class !== className)
                continue;

            const workspace = root.getWorkspace(toplevel.lastIpcObject.workspace?.id);
            if (!workspace)
                return false;

            workspace.activate();
            return true;
        }

        return false;
    }
        
    function dispatch(request: string): void {
        Hyprland.dispatch(request);
    }
    function refreshToplevels() {
        Log.info("services/Hyprland.qml",'toplevels updated');
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
                    hasWindows: ws ? ws.toplevels.values.length > 0 : false,
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
                if (!n)
                    return;

                root.rawEvent(event);

                if (["workspace", "workspacev2", "moveworkspace", "moveworkspacev2", "activespecial", "focusedmon", "focusedmonv2"].includes(n)) {
                    Hyprland.refreshWorkspaces();
                    Hyprland.refreshMonitors();
                }

                if (["openwindow", "closewindow", "movewindow", "activewindow", "activewindowv2", "changefloatingmode", "fullscreen", "pin", "minimize", "windowtitle", "windowtitlev2"].includes(n)) {
                    Hyprland.refreshToplevels();
                    Hyprland.refreshWorkspaces();
                }

                if (n.includes("workspace") || n.includes("window") || ["changefloatingmode", "fullscreen", "pin", "minimize"].includes(n)) {
                    root.refreshWorkspaces();
                    root.workspaceUpdated();
                }
            } catch (e) {
                console.warn("Event handler error:", e);
            }
        }
    }
}
