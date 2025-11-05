import Quickshell.Widgets
import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import qs.modules
import qs.components
import qs.preferences

BaseMenu {
    title: "Wallpaper"
    description: "Choose and set wallpapers for your desktop."

    BaseCard {
        InfoCard {
            icon: "info"
            title: "Wallpaper update might take a few seconds."
            description: "Whisker needs time to cache all of your color schemes."
        }

        ClippingRectangle {
            id: wpContainer
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.8
            height: width * screen.height / screen.width
            radius: 10
            color: Appearance.colors.m3surface_container

            MaterialIcon {
                anchors.centerIn: parent
                icon: "wallpaper"
                font.pixelSize: 64
                color: Appearance.colors.m3on_surface_variant
                visible: !wpImage.source || wpImage.source === ""
            }

            Image {
                id: wpImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: Preferences.wallpaper
                smooth: true
            }
        }

        BaseRowCard {
            cardMargin: 0
            verticalPadding: 0
            id: wpSelectorCard
            property var wallpapers: []

            Flickable {
                id: wpFlick
                anchors.left: parent.left
                anchors.right: parent.right
                height: 70
                clip: true
                interactive: true
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalFlick
                contentWidth: rowContent2.childrenRect.width
                contentHeight: rowContent2.childrenRect.height

                RowLayout {
                    id: rowContent2
                    spacing: 10
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom

                    Repeater {
                        model: wpSelectorCard.wallpapers
                        delegate: Item {
                            width: 120
                            height: width * screen.height / screen.width
                            property bool hovered: mouseHover.containsMouse
                            property bool selected: Preferences.wallpaper === modelData

                            MouseArea {
                                id: mouseHover
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: !wpSetProc.running
                                onClicked: {
                                    if (Preferences.wallpaper === modelData) return;
                                    wpSetProc.command = ['whisker', 'wallpaper', modelData];
                                    wpSetProc.running = true;
                                }
                            }

                            ClippingRectangle {
                                anchors.fill: parent
                                radius: 10
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
                                radius: 10
                                color: "transparent"
                                border.width: selected ? 3 : (hovered ? 2 : 1)
                                border.color: selected
                                    ? Appearance.colors.m3primary
                                    : Colors.opacify(Appearance.colors.m3on_background, hovered ? 0.6 : 0.3)
                            }
                        }
                    }
                }
            }

            // Disable all interactions while wallpaper is setting
            Rectangle {
                anchors.fill: parent
                color: Colors.opacify(Appearance.colors.m3surface, 0.4)
                visible: wpSetProc.running
                z: 999

                LoadingIcon {
                    anchors.centerIn: parent
                    visible: true
                }
            }

            Process {
                id: wpFetchProc
                command: ["whisker", "list", "wallpapers"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: {
                        wpSelectorCard.wallpapers = this.text.trim().split("\n").filter(s => s.length > 0)
                    }
                }
            }

            Process {
                id: wpSetProc
                command: []
                running: false

                stdout: StdioCollector {
                    onStreamFinished: {
                        wpImage.source = Preferences.wallpaper
                        wpSetProc.running = false
                    }
                }
            }
        }
    }
}
