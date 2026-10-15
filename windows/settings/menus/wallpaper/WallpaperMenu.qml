
import Quickshell.Widgets
import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts
import QtMultimedia

import qs.modules
import qs.components
import qs.preferences
import qs.services

import qs.windows.settings.menus.wallpaper.components

BaseMenu {
    id: root
    required property var screen
    title: "Wallpaper"
    description: "Choose and set wallpapers for your desktop."

    BaseCard {
        RowLayout {
            ClippingRectangle {
                id: wpContainer
                Layout.fillWidth: true
                Layout.preferredWidth: 580
                Layout.preferredHeight: width * root.screen.height / root.screen.width
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
            ColumnLayout {
                visible: false
                Layout.margins: 14
                StyledText {
                    text: "Additional Config"
                    font.pixelSize: 20
                    font.family: "Outfit SemiBold"
                }
                RowLayout {
                    ColumnLayout {
                        spacing: 0
                        StyledText {
                            text: "Apply to greeter"
                            font.pixelSize: 16
                            font.family: "Outfit Medium"
                        }
                        StyledText {
                            text: "Requires root privileges every wallpaper change."
                            font.pixelSize: 10
                        }
                    }
                    Item { Layout.fillWidth: true }
                    StyledSwitch {
                        checked: Preferences.misc.applyWallpaperToGreeter
                        onToggled: {
                            Whisker.setPrefs('misc.applyWallpaperToGreeter', checked)
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }
        Item {}
        BaseRowCard {
            id: wpSelectorCard
            cardMargin: 0
            verticalPadding: 8

            property var userWallpapers: []
            property var whiskerWallpapers: []
            property var wallpapers: selectedTab === 0 ? userWallpapers : whiskerWallpapers
            property var filteredWallpapers: []
            property int selectedTab: 0

            onWallpapersChanged: updateFiltered()
            onSelectedTabChanged: updateFiltered()

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Item {
                    Layout.fillWidth: true
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    height: bg.height

                    StyledRectangle {
                        id: bg
                        anchors.fill: tabContainer
                        radius: 200
                        color: Appearance.colors.m3surface_container_high
                    }

                    RowLayout {
                        id: tabContainer
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        StyledButton {
                            icon: "person"
                            text: "User"
                            iconSize: 28
                            iconGap: 10
                            radius: 200
                            vPadding: 0
                            implicitWidth: 200
                            checked: wpSelectorCard.selectedTab === 0
                            base_bg: checked ? Appearance.colors.m3secondary_container : "transparent"
                            base_fg: checked ? Appearance.colors.m3secondary : Appearance.colors.m3on_surface_variant
                            onClicked: wpSelectorCard.selectedTab = 0
                            label.font.pixelSize: 16
                        }
                        StyledButton {
                            icon: "pets"
                            text: "Whisker"
                            iconSize: 28
                            iconGap: 10
                            radius: 200
                            vPadding: 0
                            implicitWidth: 200
                            checked: wpSelectorCard.selectedTab === 1
                            base_bg: checked ? Appearance.colors.m3secondary_container : "transparent"
                            base_fg: checked ? Appearance.colors.m3secondary : Appearance.colors.m3on_surface_variant
                            onClicked: wpSelectorCard.selectedTab = 1
                            label.font.pixelSize: 16
                        }
                    }
                }

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
                        iconSize: 20
                        checkable: true
                        checked: true

                        onToggled: function(checked) {
                            if (!checked && !videoFilterBtn.checked) {
                                imageFilterBtn.checked = true
                            }

                            wpSelectorCard.updateFiltered()
                        }
                    }

                    StyledButton {
                        id: videoFilterBtn
                        icon: "videocam"
                        iconSize: 20
                        checkable: true
                        checked: true

                        onToggled: function(checked) {
                            if (!checked && !imageFilterBtn.checked) {
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
                    contentHeight: gridContent.height
                    boundsBehavior: Flickable.StopAtBounds

                    Grid {
                        id: gridContent
                        anchors.centerIn: parent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        columns: Math.floor((parent.width - 20) / 160)
                        spacing: 10

                        Repeater {
                            model: wpSelectorCard.filteredWallpapers

                            delegate: WallpaperItem {}
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

            StyledRectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
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
                var searchTerm = searchInput.text.trim().toLowerCase()

                for (var i = 0; i < wallpapers.length; i++) {
                    var wp = wallpapers[i]
                    var fileName = wp.split('/').pop().toLowerCase()
                    var matchesSearch = !searchTerm || fileName.indexOf(searchTerm) !== -1
                    var wpIsVideo = Utils.isVideo(wp)
                    var matchesFilter = (imageFilterBtn.checked && !wpIsVideo) ||
                                        (videoFilterBtn.checked && wpIsVideo)

                    if (matchesSearch && matchesFilter)
                        result.push(wp)
                }

                filteredWallpapers = result
            }

            Process {
                id: wpFetchProc
                command: ["whisker", "list", "wallpapers"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        wpSelectorCard.userWallpapers = this.text.trim()
                            .split("\n")
                            .filter(function(s) { return s.trim().length > 0 })
                    }
                }
            }

            Process {
                id: whiskerWpFetchProc
                command: ["sh", "-c", "ls -1 " + JSON.stringify(Utils.getPath("images/wallpapers"))]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        var basePath = Utils.getPath("images/wallpapers")

                        wpSelectorCard.whiskerWallpapers = this.text.trim()
                            .split("\n")
                            .filter(function(s) { return s.trim().length > 0 })
                            .map(function(file) { return basePath + "/" + file })
                    }
                }
            }

            Process {
                id: wpSetProc
                command: []
                running: false

                stdout: StdioCollector {
                    onStreamFinished: {
                        Whisker.notify("Whisker", "Wallpaper changed!")
                    }
                }
            }
        }
    }
}
