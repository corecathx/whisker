import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import qs.modules
import qs.windows
import qs.services
import qs.components
import qs.components.effects

Scope {
    id: root
    property bool active: false
    property var keybindsList: []

    FileView {
        id: keybindsFile
        path: Quickshell.shellPath("integrations/hypr-keybinds.conf")
        blockLoading: true

        onLoaded: root.parseKeybinds()
        onTextChanged: root.parseKeybinds()
    }

    function parseKeybinds() {
        var content = keybindsFile.text();
        if (!content) return;

        var lines = content.split('\n');
        var categories = [];
        var currentCategory = null;
        var currentDescription = "";

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();

            if (line.startsWith('##') && line.endsWith('##')) {
                var categoryName = line.replace(/##/g, '').trim();
                currentCategory = {
                    name: categoryName,
                    keybinds: []
                };
                categories.push(currentCategory);
            }
            else if (line.startsWith('#') && !line.startsWith('##')) {
                currentDescription = line.substring(1).trim();
            }
            else if (line.startsWith('bind')) {
                var parts = line.split(',');
                if (parts.length >= 3 && currentCategory) {
                    var bindPart = parts[0].trim();
                    var modifier = bindPart.substring(bindPart.indexOf('=') + 1).trim();
                    var key = parts[1].trim();

                    var keys = modifier.split('+').map(function(m) { return m.trim(); });
                    keys.push(key);

                    currentCategory.keybinds.push({
                        name: currentDescription,
                        keys: keys
                    });

                    currentDescription = "";
                }
            }
        }

        keybindsList = categories;
    }

    function getKeyIcon(key) {
        var k = key.toUpperCase();
        if (k === "SUPER_L" || k === "SUPER_R" || k.includes("SUPER")) return "keyboard_command_key";
        if (k.includes("CTRL") || k.includes("CONTROL")) return "keyboard_control_key";
        if (k.includes("ALT")) return "keyboard_option_key";
        if (k.includes("SHIFT")) return "shift";
        return null;
    }

    IpcHandler {
        target: "keybinds"
        function toggle() {
            root.active = !root.active;
        }
    }

    LazyLoader {
        active: root.active
        component: PanelWindow {
            id: win
            anchors {
                left: true; right: true; top: true; bottom: true;
            }
            color: Colors.opacify(Appearance.colors.m3surface, 0.2)
            mask: Region {x:container.x;y:container.y;width:container.width;height:container.height}

            MouseArea {
                anchors.fill: parent
                onClicked: root.active = false
            }

            Rectangle {
                id: container
                anchors.centerIn: parent
                width: Math.min(win.width - 80, 800)
                height: Math.min(win.height - 80, 600)
                radius: 20
                color: Appearance.colors.m3surface

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowBlur: 0.3
                    shadowOpacity: 0.25
                    shadowVerticalOffset: 6
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        StyledText {
                            text: "Keybinds"
                            font.pixelSize: 20
                            font.family: "Outfit SemiBold"
                            color: Appearance.colors.m3on_surface
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignCenter
                        }

                        StyledButton {
                            icon: "close"
                            onClicked: root.active = false

                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Colors.opacify(Appearance.colors.m3on_surface, 0.12)
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ColumnLayout {
                            width: parent.width - 20
                            spacing: 10

                            Repeater {
                                model: {
                                    Log.info("windows/keybinds/KeybindsListWindow.qml", JSON.stringify(root.keybindsList))
                                    root.keybindsList}

                                delegate: ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    StyledText {
                                        text: modelData.name
                                        font.pixelSize: 15
                                        font.weight: Font.DemiBold
                                        color: Appearance.colors.m3primary
                                        Layout.topMargin: index === 0 ? 0 : 12
                                        Layout.bottomMargin: 4
                                    }

                                    Repeater {
                                        model: modelData.keybinds

                                        delegate: RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 6

                                            Repeater {
                                                model: modelData.keys

                                                delegate: RowLayout {
                                                    spacing: 6

                                                    Rectangle {
                                                        Layout.preferredHeight: 32
                                                        Layout.preferredWidth: Math.max(keyContent.width + 16, 32)
                                                        radius: 6
                                                        bottomLeftRadius: 0
                                                        bottomRightRadius: 0
                                                        color: "transparent"
                                                        border.width: 2
                                                        border.color: Appearance.colors.m3primary

                                                        Rectangle {
                                                            anchors.left: parent.left
                                                            anchors.right: parent.right
                                                            anchors.bottom: parent.bottom
                                                            height: 3
                                                            color: Appearance.colors.m3primary
                                                            radius: 6
                                                            topLeftRadius: 0
                                                            topRightRadius: 0
                                                        }

                                                        Item {
                                                            id: keyContent
                                                            anchors.centerIn: parent
                                                            width: keyIcon.visible ? keyIcon.width : keyText.width
                                                            height: parent.height

                                                            MaterialIcon {
                                                                id: keyIcon
                                                                visible: root.getKeyIcon(modelData) !== null
                                                                icon: root.getKeyIcon(modelData) || ""
                                                                font.pixelSize: 18
                                                                color: Appearance.colors.m3primary
                                                                anchors.centerIn: parent
                                                            }

                                                            StyledText {
                                                                id: keyText
                                                                visible: !keyIcon.visible
                                                                text: modelData
                                                                font.pixelSize: 13
                                                                font.family: "monospace"
                                                                font.weight: Font.Bold
                                                                color: Appearance.colors.m3primary
                                                                anchors.centerIn: parent
                                                            }
                                                        }
                                                    }

                                                    StyledText {
                                                        visible: index < modelData.length - 1
                                                        text: "+"
                                                        font.pixelSize: 14
                                                        font.weight: Font.Bold
                                                        color: Colors.opacify(Appearance.colors.m3on_surface, 0.5)
                                                    }
                                                }
                                            }

                                            StyledText {
                                                text: modelData.name
                                                font.pixelSize: 14
                                                color: Appearance.colors.m3on_surface
                                                Layout.fillWidth: true
                                                Layout.leftMargin: 8
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
