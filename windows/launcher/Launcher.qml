import QtQuick.Layouts
import QtQuick
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
        needle = needle.toLowerCase()
        haystack = haystack.toLowerCase()
        let i = 0, j = 0
        while (i < needle.length && j < haystack.length) {
            if (needle[i] === haystack[j]) i++
            j++
        }
        return i === needle.length
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
                                    }

                                    MaterialIcon {
                                        visible: appicon.source == ""
                                        icon: "terminal"
                                        font.pixelSize: 30
                                        color: Appearance.colors.m3on_surface
                                    }

                                    ColumnLayout {
                                        spacing: 0
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
        }
    }
}
