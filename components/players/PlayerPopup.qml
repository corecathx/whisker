import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.modules
import qs.services
import qs.components

Rectangle {
    id: root
    visible: !!Players.active
    implicitHeight: mainContent.implicitHeight + 40
    implicitWidth: 320
    radius: 20
    color: Appearance.colors.m3surface

    ColumnLayout {
        id: mainContent
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        ColumnLayout {
            spacing: 15
            Layout.fillWidth: true

            Item {
                Layout.preferredWidth: 200
                Layout.preferredHeight: Layout.preferredWidth
                Layout.alignment: Qt.AlignHCenter
                Image {
                    anchors.fill: parent
                    source: Players.active?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    cache: true
                    asynchronous: true
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 1
                        blurMax: 64
                    }
                }
                ClippingRectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    radius: 10
                    color: Appearance.colors.m3surface_container_high

                    Image {
                        anchors.fill: parent
                        source: Players.active?.trackArtUrl ?? ""
                        fillMode: Image.PreserveAspectCrop
                        cache: true
                        asynchronous: true
                    }

                    MaterialIcon {
                        anchors.centerIn: parent
                        icon: "album"
                        font.pixelSize: 48
                        color: Appearance.colors.m3on_surface_variant
                        opacity: 0.3
                        visible: !Players.active?.trackArtUrl
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                spacing: 5

                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    text: Players.active?.trackTitle || "Nothing playing"
                    font.pixelSize: 16
                    font.family: "Outfit SemiBold"
                    color: Appearance.colors.m3on_surface
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    text: Players.active?.trackArtist || "Unknown artist"
                    font.pixelSize: 12
                    color: Appearance.colors.m3on_surface_variant
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    text: Players.active?.trackAlbum || ""
                    font.pixelSize: 10
                    color: Appearance.colors.m3on_surface_variant
                    opacity: 0.7
                    elide: Text.ElideRight
                    visible: text !== ""
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            StyledSlider {
                id: progressSlider
                Layout.fillWidth: true
                implicitHeight: 40
                useAnim: false
                trackHeightDiff: 28
                trackNearHandleRadius:2
                handleGap: 8
                handle.width: 8

                property bool isSeeking: false

                value: {
                    if (isSeeking) return value
                    const pos = Players.active?.position ?? 0
                    const len = Players.active?.length ?? 1
                    return len > 0 ? (pos / len) * 100 : 0
                }

                onPressedChanged: {
                    if (pressed) {
                        isSeeking = true
                    } else {
                        isSeeking = false
                        const active = Players.active
                        if (active && active.canSeek) {
                            active.position = (value / 100) * active.length
                        }
                    }
                }

                Connections {
                    target: Players.active
                    function onPositionChanged() {
                        if (!progressSlider.isSeeking) {
                            const pos = Players.active?.position ?? 0
                            const len = Players.active?.length ?? 1
                            progressSlider.value = len > 0 ? (pos / len) * 100 : 0
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 4
                Layout.rightMargin: 4

                StyledText {
                    text: formatTime(Players.active?.position ?? 0)
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: Appearance.colors.m3on_surface_variant
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: formatTime(Players.active?.length ?? 0)
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: Appearance.colors.m3on_surface_variant
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            StyledButton {
                implicitWidth: 40
                implicitHeight: 40
                radius: 20
                icon: "shuffle"
                icon_size: 18
                checkable: true
                checked: Players.active?.shuffle ?? false
                visible: Players.active?.canControl ?? false
                enabled: Players.active?.shuffleSupported ?? false
                opacity: (Players.active?.shuffleSupported ?? false) ? 1.0 : 0.35
                onClicked: {
                    if (Players.active && Players.active.canControl && Players.active.shuffleSupported) {
                        Players.active.shuffle = !Players.active.shuffle
                        checked = Players.active.shuffle
                    }
                }
            }

            StyledButton {
                implicitWidth: 48
                implicitHeight: 48
                radius: 24
                icon: "skip_previous"
                icon_size: 24
                secondary: true
                checkable: false
                visible: Players.active?.canGoPrevious ?? false
                enabled: Players.active?.canGoPrevious ?? false
                onClicked: {
                    if (Players.active && Players.active.canGoPrevious) {
                        Players.active.previous()
                    }
                }
            }

            StyledButton {
                implicitWidth: 64
                implicitHeight: 64
                radius: 32
                icon: (Players.active?.playbackState === MprisPlaybackState.Playing) ? "pause" : "play_arrow"
                icon_size: 32
                checkable: false
                onClicked: {
                    if (!Players.active) return
                    if (Players.active.playbackState === MprisPlaybackState.Playing) {
                        Players.active.pause()
                    } else {
                        Players.active.play()
                    }
                }
            }

            StyledButton {
                implicitWidth: 48
                implicitHeight: 48
                radius: 24
                icon: "skip_next"
                icon_size: 24
                secondary: true
                checkable: false
                visible: Players.active?.canGoNext ?? false
                enabled: Players.active?.canGoNext ?? false
                onClicked: {
                    if (Players.active && Players.active.canGoNext) {
                        Players.active.next()
                    }
                }
            }

            StyledButton {
                implicitWidth: 40
                implicitHeight: 40
                radius: 20
                icon: {
                    const state = Players.active?.loopState ?? MprisLoopState.None
                    if (state === MprisLoopState.Track) return "repeat_one"
                    return "repeat"
                }
                icon_size: 18
                checkable: true
                checked: (Players.active?.loopState ?? MprisLoopState.None) !== MprisLoopState.None
                visible: Players.active?.canControl ?? false
                enabled: Players.active?.loopSupported ?? false
                opacity: (Players.active?.loopSupported ?? false) ? 1.0 : 0.35
                onClicked: {
                    if (!Players.active || !Players.active.canControl || !Players.active.loopSupported) return
                    const current = Players.active.loopState
                    checked = true;
                    if (current === MprisLoopState.None) {
                        Players.active.loopState = MprisLoopState.Playlist
                    } else if (current === MprisLoopState.Playlist) {
                        Players.active.loopState = MprisLoopState.Track
                    } else {
                        Players.active.loopState = MprisLoopState.None
                        checked = false;
                    }
                }
            }
        }
        Item {}
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 5
            visible: Players.active?.identity

            MaterialIcon {
                icon: "music_note"
                font.pixelSize: 11
                color: Appearance.colors.m3on_surface_variant
                opacity: 0.4
            }

            StyledText {
                text: Players.active?.identity || ""
                font.pixelSize: 10
                color: Appearance.colors.m3on_surface_variant
                opacity: 0.6
            }
        }
    }

    function formatTime(seconds) {
        const totalSeconds = Math.floor(seconds)
        const minutes = Math.floor(totalSeconds / 60)
        const secs = totalSeconds % 60
        return minutes + ":" + (secs < 10 ? "0" : "") + secs
    }
}
