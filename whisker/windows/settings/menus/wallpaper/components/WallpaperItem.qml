import QtQuick
import QtQuick.Layouts
import QtMultimedia

import Quickshell
import Quickshell.Widgets

import qs.whisker.modules
import qs.whisker.components
import qs.whisker.preferences

Item {
    width: 150
    height: width * root.screen.height / root.screen.width + 35
    property bool hovered: mouseArea.containsMouse
    property bool selected: Preferences.theme.wallpaper === modelData
    property bool itemIsVideo: Utils.isVideo(modelData)

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !wpSetProc.running
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (selected)
                return

            wpSetProc.command = [
                "whisker",
                "wallpaper",
                modelData
            ]

            wpSetProc.running = true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        ClippingRectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.width * root.screen.height / root.screen.width
            radius: 10
            color: Appearance.colors.m3surface_container_high

            LoadingIcon {
                anchors.centerIn: parent
            }
            Image {
                anchors.fill: parent
                source: !itemIsVideo ? modelData : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                sourceSize.width: width
                sourceSize.height: height
                visible: !itemIsVideo
            }

            Video {
                id: thumbVideo
                anchors.fill: parent
                source: {
                    if (!itemIsVideo) return ""
                    return modelData.startsWith("file://") ? modelData : "file://" + modelData
                }
                autoPlay: true
                muted: true
                visible: itemIsVideo
                position: 100
                Component.onCompleted: {
                    thumbVideo.pause()
                }
                Connections {
                    target: mouseArea
                    function onContainsMouseChanged() {
                        if (itemIsVideo) {
                            if (mouseArea.containsMouse)
                                thumbVideo.play()
                            else {
                                thumbVideo.pause()
                                thumbVideo.position = 100
                            }
                        }
                    }
                }
            }

            StyledRectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 5
                width: 24
                height: 24
                radius: 12
                color: Colors.opacify(Appearance.colors.m3primary, 0.9)
                visible: itemIsVideo

                MaterialIcon {
                    anchors.centerIn: parent
                    icon: "play_circle"
                    font.pixelSize: 16
                    color: Appearance.colors.m3on_primary
                }
            }

            StyledRectangle {
                anchors.fill: parent
                radius: 10
                color: "transparent"
                border.width: selected ? 3 : (hovered ? 2 : 1)
                border.color: selected
                    ? Appearance.colors.m3primary
                    : Colors.opacify(Appearance.colors.m3on_background, hovered ? 0.6 : 0.3)
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: modelData.split('/').pop()
            color: Appearance.colors.m3on_surface
            font.pixelSize: 11
            elide: Text.ElideMiddle
            horizontalAlignment: Text.AlignHCenter
        }
    }
}