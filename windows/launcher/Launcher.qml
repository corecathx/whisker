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
                        "-i", "/home/corecat/.config/whisker/logo.png",
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
        }
    ]

    function getMatchedCommands(query) {
        let matches = [];
        for (let cmd of customCommands)
            if (query.startsWith(cmd.trigger))
                matches.push(cmd);
        return matches;
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
            property bool barIsOpaque: ((Preferences.barPosition === "bottom" && Hyprland.currentWorkspace.hasTilingWindow()) || Preferences.keepBarOpaque) || (Preferences.barPosition === "top")    
            implicitWidth: (screen.width * 0.4) + 20
            implicitHeight: (screen.height * 0.6) + 20

            anchors.bottom: true
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Normal
            color: "transparent"

            Hypr.HyprlandFocusGrab {
                id: grab
                windows: [ window ]
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
                anchors.bottomMargin: !barIsOpaque ? 10 : 0
                Behavior on anchors.bottomMargin {
                    NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic }
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowOpacity: 1
                    shadowColor: Appearance.colors.m3shadow
                    shadowBlur: 1
                    shadowScale: 1
                }

                Rectangle {
                    id: bgRectangle
                    anchors.fill: parent
                    color: Appearance.panel_color
                    topLeftRadius: 20
                    topRightRadius: 20
                    bottomLeftRadius: !barIsOpaque ? 20 : 0
                    bottomRightRadius: !barIsOpaque ? 20 : 0

                    Behavior on bottomLeftRadius {
                        NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic }
                    }
                    Behavior on bottomRightRadius {
                        NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic }
                    }
                    // LEFT CORNER
                    SingleCorner {
                        visible: barIsOpaque
                        cornerType: "inverted"
                        cornerHeight: 20
                        cornerWidth: 20
                        color: Appearance.panel_color
                        corner: 3
                        anchors.right: bgRectangle.left
                        anchors.bottom: bgRectangle.bottom
                    }

                    // RIGHT CORNER
                    SingleCorner {
                        visible: barIsOpaque
                        cornerType: "inverted"
                        cornerHeight: 20
                        cornerWidth: 20
                        color: Appearance.panel_color
                        corner: 2
                        anchors.left: bgRectangle.right
                        anchors.bottom: bgRectangle.bottom
                    }
                }

                Flickable {
                    id: listFlick
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: searchField.top
                        leftMargin: 20
                        topMargin: 20
                        rightMargin: 20
                        //margins: 0
                    }
                    contentWidth: width
                    contentHeight: column.implicitHeight
                    clip: true

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
                                    color: hovered
                                        ? Appearance.colors.m3surface_container_low
                                        : Appearance.colors.m3surface

                                    Behavior on color {
                                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
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

                                            Text {
                                                text: modelData.name
                                                font.pixelSize: 16
                                                font.bold: true
                                                color: Appearance.colors.m3on_surface
                                                Layout.fillWidth: true
                                            }
                                            Text {
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
                    }
                }

                Item {
                    id: emptyOverlay
                    anchors.fill: parent
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
                        anchors.centerIn: parent
                        Layout.bottomMargin: 50
                        spacing: 20
                        Image {
                            source: Utils.getPath("images/sad-cat.png")
                            sourceSize: Qt.size(150,150)
                            smooth: true
                            Layout.alignment: Qt.AlignVCenter
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                colorization: 1.0
                                colorizationColor: Appearance.colors.m3on_surface_variant
                            }
                        }

                        Text {
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
                }
            }
        }
    }
}
