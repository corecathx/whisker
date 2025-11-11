import Quickshell.Widgets
import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts
import QtMultimedia

import qs.modules
import qs.components
import qs.preferences

BaseMenu {
    title: "Wallpaper"
    description: "Choose and set wallpapers for your desktop."

    BaseCard {
        ClippingRectangle {
            id: wpContainer
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.9
            height: width * screen.height / screen.width
            radius: 10
            color: Appearance.colors.m3surface_container

            MaterialIcon {
                anchors.centerIn: parent
                icon: "wallpaper"
                font.pixelSize: 64
                color: Appearance.colors.m3on_surface_variant
                visible: !wpImage.visible && !wpVideoPreview.visible
            }

            Image {
                id: wpImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: {
                    var wp = Preferences.theme.wallpaper
                    if (!wp || Utils.isVideo(wp)) return ""
                    return wp
                }
                smooth: true
                visible: source !== ""
            }

            Video {
                id: wpVideoPreview
                anchors.fill: parent
                source: {
                    var wp = Preferences.theme.wallpaper
                    if (!wp || !Utils.isVideo(wp)) return ""
                    return wp.startsWith("file://") ? wp : "file://" + wp
                }
                autoPlay: true
                loops: MediaPlayer.Infinite
                muted: true
                visible: source !== ""
            }

        }

        BaseRowCard {
            cardMargin: 0
            verticalPadding: 8
            id: wpSelectorCard
            property var wallpapers: []
            property var filteredWallpapers: []

            onWallpapersChanged: updateFiltered()

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    spacing: 10

                    StyledTextField {
                        id: searchInput
                        Layout.fillWidth: true
                        icon: "search"
                        placeholder: "Search wallpapers..."
                        fieldPadding: 12
                        iconSize: 20
                        font.pixelSize: 14
                        onTextChanged: wpSelectorCard.updateFiltered()
                    }

                    StyledButton {
                        id: imageFilterBtn
                        icon: "image"
                        icon_size: 20
                        checkable: true
                        checked: true
                        onToggled: function(checked) {
                            if (!checked && !videoFilterBtn.checked) {
                                checked = true
                                imageFilterBtn.checked = true
                            }
                            wpSelectorCard.updateFiltered()
                        }
                    }

                    StyledButton {
                        id: videoFilterBtn
                        icon: "videocam"
                        icon_size: 20
                        checkable: true
                        checked: true
                        onToggled: function(checked) {
                            if (!checked && !imageFilterBtn.checked) {
                                checked = true
                                videoFilterBtn.checked = true
                            }
                            wpSelectorCard.updateFiltered()
                        }
                    }
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 400
                    clip: true
                    contentWidth: width
                    contentHeight: gridContent.childrenRect.height
                    boundsBehavior: Flickable.StopAtBounds

                    Grid {
                        id: gridContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        columns: Math.floor((parent.width - 20) / 160)
                        spacing: 10

                        Repeater {
                            model: wpSelectorCard.filteredWallpapers

                            delegate: Item {
                                width: 150
                                height: width * screen.height / screen.width + 35
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
                                        if (selected) return
                                        wpSetProc.command = ['whisker', 'wallpaper', modelData]
                                        wpSetProc.running = true
                                    }
                                }

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 5

                                    ClippingRectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: parent.width * screen.height / screen.width
                                        radius: 10
                                        color: Appearance.colors.m3surface_container_high

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

                                        Rectangle {
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
                        }
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    text: wpSelectorCard.filteredWallpapers.length + " wallpaper" +
                          (wpSelectorCard.filteredWallpapers.length !== 1 ? "s" : "") + " found"
                    color: Appearance.colors.m3on_surface_variant
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignRight
                }
            }

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

            function updateFiltered() {
                var result = []
                var searchTerm = searchInput.text.toLowerCase()

                for (var i = 0; i < wallpapers.length; i++) {
                    var wp = wallpapers[i]
                    var fileName = wp.split('/').pop().toLowerCase()
                    var matchesSearch = !searchTerm || fileName.indexOf(searchTerm) !== -1
                    var wpIsVideo = Utils.isVideo(wp)
                    var matchesFilter = (imageFilterBtn.checked && !wpIsVideo) ||
                                        (videoFilterBtn.checked && wpIsVideo)

                    if (matchesSearch && matchesFilter) {
                        result.push(wp)
                    }
                }

                filteredWallpapers = result
            }

            Process {
                id: wpFetchProc
                command: ["whisker", "list", "wallpapers"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: {
                        var lines = this.text.trim().split("\n").filter(function(s) { return s.length > 0 })
                        wpSelectorCard.wallpapers = lines
                    }
                }
            }

            Process {
                id: wpSetProc
                command: []
                running: false
                stdout: StdioCollector {
                    onStreamFinished: {
                        wpSetProc.running = false
                    }
                }
            }
        }
    }
}
