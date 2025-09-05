import QtQuick
import QtQml.Models
import QtQuick.Layouts
import qs.modules
import qs.services

Item {
    id: root
    width: 400
    height: 30

    property int minWorkspaces: 4
    property int currentWorkspace: Hyprland.activeWsId

    ListModel { id: wsModel }

    function refreshWorkspaces() {
        const real = Hyprland.workspaces?.values || [];
        const sorted = real.slice().sort((a, b) => a.id - b.id);

        const maxCount = Math.max(minWorkspaces, ...sorted.map(w => w.id));
        const data = [];

        for (let i = 1; i <= maxCount; i++) {
            const ws = sorted.find(w => w.id === i);
            data.push({
                id: i,
                focused: ws ? ws.focused : (currentWorkspace === i),
                name: ws ? ws.name : ""
            });
        }

        if (wsModel.count !== data.length) {
            wsModel.clear();
            data.forEach(item => wsModel.append(item));
        } else {
            for (let i = 0; i < data.length; i++)
                wsModel.set(i, data[i]);
        }
    }

    Component.onCompleted: refreshWorkspaces()

    Connections {
        target: Hyprland
        function onActiveWsIdChanged() {
            currentWorkspace = Hyprland.activeWsId;
            refreshWorkspaces();
        }
        function onWorkspacesChanged() { refreshWorkspaces(); }
    }

    Row {
        id: pills
        anchors.centerIn: parent
        spacing: 10

        Repeater {
            model: wsModel

            delegate: Rectangle {
                id: pill
                width: focused ? 20 : 10
                height: 10
                radius: 20
                anchors.verticalCenter: parent.verticalCenter
                opacity: focused ? 1.0 : 0.4
                color: Appearance.colors.m3on_background
                               

                Behavior on width { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic } }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (Hyprland.activeWsId !== id) Hyprland.dispatch(`workspace ${id}`)
                }
            }
        }
    }
}
