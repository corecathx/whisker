import QtQuick.Layouts
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.modules
import qs.components

Scope {
    id: root
    property bool opened: false

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
            margins.bottom: 10
            implicitWidth: screen.width * 0.4
            implicitHeight: screen.height * 0.5
            anchors.bottom: true
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Normal
            color: "transparent"

            HyprlandFocusGrab {
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
                    if (!grab.active) {
                        root.opened = false
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Appearance.panel_color
                radius: 20
            }

            StyledTextField {
                id: searchField
                icon: "search"
                placeholder: "Search"
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 20
                }
            }

            Flickable {
                id: listFlick
                anchors {
                    left: parent.left
                    right: parent.right
                    top: searchField.bottom
                    bottom: parent.bottom
                    margins: 20
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
                            let appsArray = DesktopEntries.applications.values
                            appsArray = appsArray.slice().sort(
                                (a, b) => a.name.localeCompare(b.name, Qt.locale().name)
                            )
                            return appsArray
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
                                    ? Appearance.colors.m3surface_container_high
                                    : Appearance.colors.m3surface_container_low

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
                                        source: Quickshell.iconPath(modelData.icon, true)
                                        visible: source != ""
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                        sourceSize.width: 30
                                        sourceSize.height: 30
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    MaterialIcon {
                                        visible: appicon.source == ""
                                        icon: "terminal"
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
                        spacing: 20
                        height: parent.height
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
            }

        }
    }
}
