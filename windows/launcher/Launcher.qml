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

    property var customCommands: [
        {
            name: "Calculator",
            trigger: "=",
            comment: "Perform quick math calculations",
            icon: "calculate",
            exec: function(input) {
                try {
                    return eval(input.substring(1));
                } catch(e) {
                    return "Invalid syntax.";
                }
            }
        },
        {
            name: "Hello",
            trigger: "!",
            comment: "Say hello to Whisker!",
            icon: "pets",
            autoRun: false,
            exec: function(input) {
                Quickshell.execDetached({
                    command: [
                        "dunstify",
                        "-i", Utils.getPath("logo.png"),
                        "Whisker",
                        "Hello, " + Quickshell.env("USER") + "!"
                    ]
                })
            }
        },
        {
            name: "Web Search",
            trigger: "?",
            comment: "Search the web",
            icon: "globe",
            autoRun: false,
            exec: function(input) {
                Quickshell.execDetached({
                    command: [
                        "xdg-open",
                        "https://www.google.com/search?q=" + encodeURIComponent(input.substring(1))
                    ]
                })
            }
        },
        {
            name: "Set Wallpaper",
            trigger: ">wallpaper",
            comment: "Set your wallpaper.",
            icon: "wallpaper",
            autoRun: false,
            exec: function(input) {
                Quickshell.execDetached({
                    command: [
                        "xdg-open",
                        "https://www.google.com/search?q=" + encodeURIComponent(input.substring(1))
                    ]
                })
            }
        },
        {
            name: "Set Theme",
            trigger: ">theme",
            comment: "Search the web",
            icon: "globe",
            autoRun: false,
            exec: function(input) {
                Quickshell.execDetached({
                    command: [
                        "xdg-open",
                        "https://www.google.com/search?q=" + encodeURIComponent(input.substring(1))
                    ]
                })
            }
        }
    ]

    function getMatchedCommands(query) {
        return customCommands.filter(cmd =>
            query.startsWith(cmd.trigger) || cmd.trigger.startsWith(query)
        );
    }



    IpcHandler {
        target: "launcher"
        function toggle() {
            root.opened = !root.opened
        }
    }

    function fuzzyMatch(needle, haystack) {
        return substringMatch(needle, haystack)
    }
    function substringMatch(needle, haystack) {
        return haystack.toLowerCase().includes(needle.toLowerCase());
    }


    LazyLoader {
        active: root.opened
        PanelWindow {
            id: window
            property int selectedIndex: -1  // Track selected item
            property bool barIsOpaque: ((Preferences.barPosition === "bottom" && Hyprland.currentWorkspace.hasTilingWindow()) || Preferences.keepBarOpaque) || (Preferences.barPosition === "top")
            implicitWidth: (screen.width * 0.4) + 20
            implicitHeight: (screen.height * 0.6) + 20

            anchors.bottom: true
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Normal
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "transparent"

            Hypr.HyprlandFocusGrab {
                id: grab
                windows: [ window ]
            }

            mask: Region {
                width: window.width
                height: bgRectangle.height
            }

            onVisibleChanged: {
                if (visible) {
                    grab.active = true
                    searchField.text = ""
                    searchField.focus = true
                }
            }

            Connections {
                target: grab
                function onActiveChanged() {
                    if (!grab.active)
                        root.opened = false
                }
            }

            Item {
                anchors.fill: parent
                anchors.topMargin: 20
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                anchors.bottomMargin: 10
                Behavior on anchors.bottomMargin {
                    NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowOpacity: 1
                    shadowColor: Appearance.colors.m3shadow
                    shadowBlur: 1
                    shadowScale: 1
                }

                Keys.onPressed: {
                    const visibleItems = getVisibleItems()
                    if (event.key === Qt.Key_Down) {
                        event.accepted = true
                        if (visibleItems.length > 0) {
                            selectedIndex = Math.min(selectedIndex + 1, visibleItems.length - 1)
                            scrollToSelected(visibleItems)
                        }
                    } else if (event.key === Qt.Key_Up) {
                        event.accepted = true
                        if (visibleItems.length > 0) {
                            selectedIndex = Math.max(selectedIndex - 1, 0)
                            scrollToSelected(visibleItems)
                        }
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        event.accepted = true
                        if (selectedIndex >= 0 && selectedIndex < visibleItems.length) {
                            visibleItems[selectedIndex].storedModelData.execute()
                            root.opened = false
                        }
                    } else if (event.key === Qt.Key_Escape) {
                        event.accepted = true
                        root.opened = false
                    }
                }

                function getVisibleItems() {
                    let items = []
                    for (let i = 0; i < appRepeater.count; i++) {
                        const it = appRepeater.itemAt(i)
                        if (it && it.visible)
                            items.push(it)
                    }
                    return items
                }

                function scrollToSelected(visibleItems) {
                    const item = visibleItems[selectedIndex]
                    if (item) {
                        listFlick.contentY = item.y
                        for (let i = 0; i < visibleItems.length; i++)
                            visibleItems[i].children[0].selected = (i === selectedIndex)
                    }
                }

                Rectangle {
                    id: bgRectangle
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: listFlick.height + searchField.height + 60
                    color: Appearance.panel_color
                    radius: 20

                    Behavior on bottomLeftRadius {
                        NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
                    }
                    Behavior on bottomRightRadius {
                        NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
                    }
                }

                Item {
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: bgRectangle.top
                        bottom: searchField.top
                        leftMargin: 20
                        topMargin: 40
                        bottomMargin: 20
                        rightMargin: 20
                        //margins: 0
                    }
                    Flickable {
                        id: listFlick
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom

                            //margins: 0
                        }
                        contentWidth: width
                        contentHeight: column.implicitHeight
                        Behavior on contentY {
                            NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
                        }

                        clip: true
                        height: Math.min(column.implicitHeight, window.implicitHeight - 140)
                        Behavior on height {
                            NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
                        }
                        Column {
                            id: column
                            width: parent.width
                            spacing: 10

                            Repeater {
                                id: appRepeater
                                model: {
                                    let query = searchField.text.trim();
                                    let appsArray = DesktopEntries.applications.values.slice().sort(
                                        (a, b) => a.name.localeCompare(b.name, Qt.locale().name)
                                    );

                                    if (query !== "") {
                                        let commands = getMatchedCommands(query);
                                        for (let cmd of commands) {
                                            let result = cmd.comment
                                            if (cmd.autoRun ?? true)
                                                result = cmd.exec(query) ?? cmd.comment;
                                            appsArray.unshift({
                                                name: cmd.name,
                                                comment: String(result),
                                                execString: query,
                                                execute: function() {
                                                    if (!cmd.autoRun) {
                                                        cmd.exec(query)
                                                    }
                                                    root.opened = false;
                                                },
                                                icon: "whisker:" + cmd.icon
                                            });
                                        }
                                    }

                                    return appsArray;
                                }



                                delegate: Item {
                                    property var storedModelData: modelData
                                    width: parent.width
                                    height: visible ? 60 : 0
                                    visible: searchField.text.trim() === "" ||
                                        fuzzyMatch(searchField.text,
                                                modelData.name + " " +
                                                modelData.comment + " " +
                                                modelData.execString)

                                    Rectangle {
                                        id: appItem
                                        anchors.fill: parent
                                        radius: 20
                                        color: selected || hovered
                                            ? Appearance.colors.m3surface_container_low
                                            : Appearance.colors.m3surface

                                        Behavior on color {
                                            ColorAnimation { duration: 200; easing.type: Appearance.animation.easing }
                                        }

                                        MouseArea {
                                            id: mouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                modelData.execute()
                                                root.opened = false
                                            }
                                        }
                                        property bool hovered: mouseArea.containsMouse
                                        property bool selected: false

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            anchors.leftMargin: 20
                                            spacing: 20

                                            Image {
                                                id: appicon
                                                asynchronous: true
                                                cache: true
                                                source: {
                                                    if (modelData.icon.startsWith("whisker:"))
                                                        return ""
                                                    return Quickshell.iconPath(modelData.icon, true)

                                                }
                                                visible: source != ""
                                                fillMode: Image.PreserveAspectCrop
                                                smooth: true
                                                sourceSize.width: 30
                                                sourceSize.height: 30
                                                Layout.alignment: Qt.AlignVCenter
                                            }

                                            MaterialIcon {
                                                visible: appicon.source == ""
                                                icon: {
                                                    if (modelData.icon.startsWith("whisker:"))
                                                        return modelData.icon.replace("whisker:", "")
                                                    return "terminal"
                                                }
                                                font.pixelSize: 30
                                                color: Appearance.colors.m3on_surface
                                                Layout.alignment: Qt.AlignVCenter
                                            }

                                            ColumnLayout {
                                                spacing: 0
                                                Layout.fillWidth: true

                                                StyledText {
                                                    text: modelData.name
                                                    font.pixelSize: 16
                                                    font.bold: true
                                                    color: Appearance.colors.m3on_surface
                                                    Layout.fillWidth: true
                                                }
                                                StyledText {
                                                    visible: text !== ""
                                                    text: {
                                                        if (modelData.comment === "")
                                                            return "> " + modelData.execString
                                                        return modelData.comment
                                                    }
                                                    font.pixelSize: 12
                                                    font.family: text.startsWith(">")
                                                        ? "monospace"
                                                        : Qt.application.font.family
                                                    color: Appearance.colors.m3on_surface_variant
                                                    Layout.fillWidth: true
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Item {
                                id: emptyOverlay
                                Layout.alignment: Qt.AlignHCenter
                                implicitWidth: parent.width
                                implicitHeight: emptyOverlayRow.height
                                z: 1
                                visible: {
                                    if (searchField.text.trim() === "") return false
                                    for (let i = 0; i < appRepeater.count; i++) {
                                        const it = appRepeater.itemAt(i)
                                        if (it && it.visible) return false
                                    }
                                    return true
                                }


                                RowLayout {
                                    id: emptyOverlayRow
                                    anchors.centerIn: parent
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.bottomMargin: 50
                                    spacing: 20
                                    Image {
                                        source: Utils.getPath("images/nothing-found.png")
                                        sourceSize: Qt.size(200,200)
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
                                            font.pixelSize: 32
                                            font.bold: true
                                            color: Appearance.colors.m3on_surface_variant
                                            Layout.alignment: Qt.AlignVCenter
                                            horizontalAlignment: Text.AlignLeft
                                            wrapMode: Text.NoWrap
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                StyledTextField {
                    id: searchField
                    icon: "search"
                    placeholder: "Search"
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        margins: 20
                    }
                    onTextChanged: {
                        selectedIndex = 0
                        parent.scrollToSelected(parent.getVisibleItems())
                    }
                }
            }
        }
    }
}
