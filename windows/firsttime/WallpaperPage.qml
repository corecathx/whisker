import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.modules
import qs.components
import qs.preferences

SetupMenu {
    id: root
    title: "Wallpaper"
    canContinue: Preferences.theme.wallpaper !== ""
    description: "Pick something cool"
    blockedMessage: "Please select a wallpaper before continuing"

    ClippingRectangle {
        Layout.preferredWidth: parent.width * 0.6
        Layout.alignment: Qt.AlignCenter
        Layout.preferredHeight: width * screen.height / screen.width
        radius: 16
        color: Appearance.colors.m3surface_container

        MaterialIcon {
            anchors.centerIn: parent
            icon: "wallpaper"
            font.pixelSize: 48
            color: Appearance.colors.m3on_surface_variant
            opacity: 0.5
        }

        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: Preferences.theme.wallpaper
            smooth: true
        }
    }

    Item {
        Layout.fillWidth: true
        height: 80
        id: wpSelectorCard
        property var wallpapers: []

        Flickable {
            anchors.fill: parent
            clip: true
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.HorizontalFlick
            contentWidth: wpRow.width
            contentHeight: wpRow.height

            Row {
                id: wpRow
                spacing: 10
                height: parent.height

                Repeater {
                    model: wpSelectorCard.wallpapers
                    delegate: Item {
                        width: 120
                        height: width * screen.height / screen.width
                        property bool hovered: wpMouse.containsMouse
                        property bool selected: Preferences.theme.wallpaper === modelData

                        MouseArea {
                            id: wpMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (Preferences.theme.wallpaper === modelData) return;
                                Quickshell.execDetached({
                                    command: ['whisker', 'wallpaper', modelData]
                                });
                            }
                        }

                        ClippingRectangle {
                            anchors.fill: parent
                            radius: 8
                            color: Appearance.colors.m3surface_container_high

                            Image {
                                anchors.fill: parent
                                source: modelData
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                sourceSize.width: width
                                sourceSize.height: height
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: "transparent"
                            border.width: selected ? 2 : (hovered ? 2 : 1)
                            border.color: selected
                                ? Appearance.colors.m3primary
                                : Colors.opacify(Appearance.colors.m3on_background, hovered ? 0.6 : 0.3)
                        }
                    }
                }
            }
        }

        Process {
            command: ["whisker", "list", "wallpapers"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    wpSelectorCard.wallpapers = this.text.trim().split("\n").filter(s => s.length > 0)
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true

        MaterialIcon {
            icon: "info"
            color: Appearance.colors.m3on_surface
            font.pixelSize: 20
        }

        StyledText {
            text: "Don't see your wallpapers? Make sure your wallpaper is placed under ~/Pictures/wallpapers folder!"
            color: Appearance.colors.m3on_surface
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }
}
