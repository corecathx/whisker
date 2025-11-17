import QtQuick.Layouts
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland as Hypr
import Quickshell.Widgets
import qs.modules
import qs.modules.corners
import qs.components
import qs.preferences
import qs.services

Scope {
    id: root
    property bool opened: false
    property var menuStack: []
    property var currentMenu: null
    property var commands: Commands.commands

    property var sortedApps: []

    Component.onCompleted: {
        sortedApps = DesktopEntries.applications.values.slice().sort((a, b) => a.name.localeCompare(b.name, Qt.locale().name));
    }

    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            sortedApps = DesktopEntries.applications.values.slice().sort((a, b) => a.name.localeCompare(b.name, Qt.locale().name));
        }
    }

    function getMatchedCommand(query) {
        const trimmed = query.trim();
        for (let i = 0; i < commands.length; i++) {
            if (trimmed.startsWith(commands[i].trigger)) {
                return commands[i];
            }
        }
        return null;
    }

    function getCommandSuggestions(query) {
        const trimmed = query.trim().toLowerCase();
        if (!trimmed.startsWith("/"))
            return [];

        let suggestions = [];
        for (let i = 0; i < commands.length; i++) {
            if (commands[i].trigger.toLowerCase().startsWith(trimmed)) {
                suggestions.push(commands[i]);
            }
        }
        return suggestions;
    }

    function executeCommand(cmd, input) {
        if (cmd.mode === "menu") {
            menuStack = [
                {
                    items: cmd.menu,
                    title: cmd.name
                }
            ];
            currentMenu = cmd.menu;
        } else if (cmd.mode === "inline") {
            return cmd.exec ? cmd.exec(input) : null;
        } else if (cmd.mode === "direct") {
            if (cmd.exec)
                cmd.exec(input);
            root.opened = false;
        }
    }

    function navigateToSubmenu(menuItem) {
        if (menuItem.submenu) {
            menuStack.push({
                items: menuItem.submenu,
                title: menuItem.name
            });
            currentMenu = menuItem.submenu;
        } else if (menuItem.exec) {
            menuItem.exec();
            root.opened = false;
        }
    }

    function navigateBack() {
        if (menuStack.length > 1) {
            menuStack.pop();
            currentMenu = menuStack[menuStack.length - 1].items;
        } else if (menuStack.length === 1) {
            menuStack = [];
            currentMenu = null;
        }
    }

    function fuzzyMatch(needle, haystack) {
        return haystack.toLowerCase().includes(needle.toLowerCase());
    }

    IpcHandler {
        target: "launcher"
        function toggle() {
            root.opened = !root.opened;
        }
    }

    LazyLoader {
        active: root.opened

        PanelWindow {
            id: window
            property int selectedIndex: 0

            implicitWidth: (screen.width * 0.4) + 20
            implicitHeight: (screen.height * 0.6) + 20

            anchors.bottom: true
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Normal
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "transparent"

            Hypr.HyprlandFocusGrab {
                id: grab
                windows: [window]
            }

            mask: Region {
                width: window.width
                height: bgRectangle.height
            }

            onVisibleChanged: {
                if (visible) {
                    grab.active = true;
                    searchField.text = "";
                    searchField.focus = true;
                    menuStack = [];
                    currentMenu = null;
                    selectedIndex = 0;
                }
            }

            Connections {
                target: grab
                function onActiveChanged() {
                    if (!grab.active)
                        root.opened = false;
                }
            }

            Item {
                id: mainContainer
                anchors.fill: parent
                anchors.topMargin: 20
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                anchors.bottomMargin: 10

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Appearance.colors.m3shadow
                    shadowBlur: 1
                }

                Keys.onPressed: {
                    if (event.key === Qt.Key_Down) {
                        event.accepted = true;
                        if (listView.count > 0) {
                            selectedIndex = (selectedIndex + 1) % listView.count;
                            listView.currentIndex = selectedIndex;
                        }
                    } else if (event.key === Qt.Key_Up) {
                        event.accepted = true;
                        if (listView.count > 0) {
                            selectedIndex = (selectedIndex - 1 + listView.count) % listView.count;
                            listView.currentIndex = selectedIndex;
                        }
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        event.accepted = true;
                        if (selectedIndex < listView.count) {
                            const itemData = listView.model[selectedIndex];
                            handleItemClick(itemData);
                        }
                    } else if (event.key === Qt.Key_Escape) {
                        event.accepted = true;
                        if (menuStack.length > 0) {
                            navigateBack();
                            selectedIndex = 0;
                        } else {
                            root.opened = false;
                        }
                    } else if (event.key === Qt.Key_Backspace) {
                        if (searchField.text === "" && menuStack.length > 0) {
                            event.accepted = true;
                            navigateBack();
                            selectedIndex = 0;
                        }
                    }
                }

                function handleItemClick(itemData) {
                    if (itemData.execute) {
                        itemData.execute();
                        if (itemData.icon && itemData.icon.startsWith('whisker:')) {
                            console.log(`${itemData.name} is a whisker command, no action has taken`);
                        } else {
                            console.log(`${itemData.name} is not a whisker command, closing launcher`);
                            root.opened = false;
                        }
                    } else if (itemData.submenu) {
                        navigateToSubmenu(itemData);
                    } else if (itemData.exec) {
                        itemData.exec();
                        root.opened = false;
                    }
                }

                Rectangle {
                    id: bgRectangle
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: listView.height + searchField.height + breadcrumbArea.height + 60
                    color: Appearance.panel_color
                    radius: 20

                    Behavior on height {
                        NumberAnimation {
                            duration: Appearance.animation.fast
                            easing.type: Appearance.animation.easing
                        }
                    }
                }

                Item {
                    id: breadcrumbArea
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: bgRectangle.top
                    anchors.topMargin: 15
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    height: menuStack.length > 0 ? 40 : 0
                    visible: menuStack.length > 0

                    RowLayout {
                        anchors.fill: parent
                        spacing: 10

                        MaterialIcon {
                            icon: "arrow_back"
                            font.pixelSize: 20
                            color: Appearance.colors.m3on_surface

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -5
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    navigateBack();
                                    selectedIndex = 0;
                                }
                            }
                        }

                        StyledText {
                            text: menuStack.length > 0 ? menuStack[menuStack.length - 1].title : ""
                            font.pixelSize: 18
                            font.bold: true
                            color: Appearance.colors.m3on_surface
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                    }
                }

                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: breadcrumbArea.bottom
                    height: listView.height - (searchField.implicitHeight - 20)
                    anchors.leftMargin: 20
                    anchors.topMargin: breadcrumbArea.visible ? 50 : 50
                    anchors.bottomMargin: 20
                    anchors.rightMargin: 20

                    ListView {
                        id: listView
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        clip: true
                        height: Math.min(contentHeight, window.implicitHeight - 140)
                        interactive: contentHeight > height
                        spacing: 10

                        // only render visible items + some buffer
                        cacheBuffer: 300

                        // smooth scrolling
                        highlightFollowsCurrentItem: true
                        highlightMoveDuration: Appearance.animation.fast

                        model: {
                            let query = searchField.text.trim();

                            if (currentMenu !== null) {
                                return currentMenu;
                            }

                            const matchedCmd = getMatchedCommand(query);
                            if (matchedCmd) {
                                if (matchedCmd.mode === "inline") {
                                    const result = matchedCmd.exec(query);
                                    return [
                                        {
                                            name: matchedCmd.name,
                                            comment: String(result),
                                            icon: "whisker:" + matchedCmd.icon,
                                            execute: function () {
                                                if (matchedCmd.onExecute) {
                                                    matchedCmd.onExecute(query);
                                                }
                                                root.opened = false;
                                            }
                                        }
                                    ];
                                } else if (matchedCmd.mode === "menu") {
                                    return currentMenu || [];
                                }
                            }

                            const suggestions = getCommandSuggestions(query);
                            if (query.startsWith("/") && suggestions.length > 0) {
                                return suggestions.map(cmd => ({
                                            name: cmd.trigger,
                                            comment: cmd.comment,
                                            icon: "whisker:" + cmd.icon,
                                            execute: function () {
                                                if (cmd.mode === "menu") {
                                                    executeCommand(cmd, cmd.trigger);
                                                } else if (cmd.mode === "direct") {
                                                    cmd.exec(cmd.trigger);
                                                    root.opened = false;
                                                } else {
                                                    searchField.text = cmd.trigger + " ";
                                                }
                                            }
                                        }));
                            }

                            // filter apps based on search
                            if (query === "") {
                                return sortedApps;
                            }

                            let filtered = [];
                            for (let i = 0; i < sortedApps.length; i++) {
                                const app = sortedApps[i];
                                if (fuzzyMatch(query, app.name + " " + (app.comment || "") + " " + (app.execString || ""))) {
                                    filtered.push(app);
                                }
                            }
                            return filtered;
                        }

                        delegate: LauncherItem {
                            required property var modelData
                            required property int index

                            itemData: modelData
                            width: listView.width
                            selected: listView.currentIndex === index

                            onClicked: {
                                mainContainer.handleItemClick(modelData);
                            }
                        }

                        // empty state
                        footer: Item {
                            width: listView.width
                            height: listView.count === 0 && searchField.text.trim() !== "" ? 200 : 0
                            visible: height > 0

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 20

                                Image {
                                    source: Utils.getPath("images/nothing-found.png")
                                    sourceSize: Qt.size(150, 150)
                                    smooth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    layer.enabled: true
                                    layer.effect: MultiEffect {
                                        colorization: 1.0
                                        colorizationColor: Appearance.colors.m3on_surface_variant
                                    }
                                }

                                ColumnLayout {
                                    StyledText {
                                        text: "Nothing found."
                                        font.pixelSize: 28
                                        font.bold: true
                                        color: Appearance.colors.m3on_surface_variant
                                    }
                                    StyledText {
                                        text: "Try a different search"
                                        font.pixelSize: 14
                                        color: Appearance.colors.m3on_surface_variant
                                    }
                                }
                            }
                        }
                    }
                }

                StyledTextField {
                    id: searchField
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 20

                    icon: currentMenu !== null ? "" : "search"
                    placeholder: currentMenu !== null ? "Select an option..." : "Search or type /"
                    readOnly: currentMenu !== null
                    opacity: currentMenu !== null ? 0.5 : 1.0

                    onTextChanged: {
                        if (currentMenu === null) {
                            selectedIndex = 0;
                            listView.currentIndex = 0;
                            listView.positionViewAtBeginning();
                        }
                    }
                }
            }
        }
    }
}
