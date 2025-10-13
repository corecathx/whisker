import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets
import Quickshell.Wayland
import qs.modules
import qs.services
import qs.components
import QtQuick.Layouts
import QtQuick.Effects
import QtMultimedia

Rectangle {
    id: musicPlayer
    clip: true
    visible: !!Players.active

    property int artSize: 80
    property int artRadius: artSize / 2
    property int titleSize: 16
    property int artistSize: 12
    property int iconSize: 46
    property int panelRadius: 80
    property int padding: 10
    property int spacing: 10
    property int sliderHeight: 20

    radius: panelRadius
    color: Appearance.colors.m3background

    implicitHeight: child.implicitHeight + padding * 2
    Layout.minimumWidth: 200
    implicitWidth: child.implicitWidth + padding * 2

    ColumnLayout {
        id: child
        anchors.fill: parent
        anchors.margins: padding
        spacing: 0

        RowLayout {
            spacing: musicPlayer.spacing
            Layout.fillWidth: true

            // Album art
            ClippingRectangle {
                id: coverParent
                property bool hovered: false
                width: artSize
                height: artSize
                radius: artRadius
                clip: true
                color: "black"

                Image {
                    anchors.fill: parent
                    source: Players.active?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    cache: true

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        autoPaddingEnabled: false
                        blurEnabled: true
                        blur: coverParent.hovered ? 1 : 0
                        blurMax: 28
                        Behavior on blur {
                            NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: Colors.opacify(Appearance.colors.m3surface, coverParent.hovered ? 0.6 : 0)
                    Behavior on color {
                        ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
                    }
                }

                MaterialIcon {
                    icon: Players.active?.isPlaying ? "play_arrow" : "pause"
                    color: Appearance.colors.m3on_surface
                    font.pixelSize: iconSize
                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    opacity: coverParent.hovered ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: coverParent.hovered = true
                    onExited: coverParent.hovered = false
                    onClicked: {
                        if (!Players.active) return
                        if (Players.active.isPlaying)
                            Players.active.pause()
                        else
                            Players.active.play()
                    }
                }
            }

            // Text + slider
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                StyledText {
                    text: {
                        const title = Players.active?.trackTitle ?? "Unknown Title"
                        return title.length > 30 ? title.substring(0, 30) + "..." : title
                    }
                    font.pixelSize: titleSize
                    font.bold: true
                    color: Appearance.colors.m3on_background
                    elide: Text.ElideRight
                }

                StyledText {
                    text: {
                        const artist = Players.active?.trackArtist ?? "Unknown Artist"
                        return artist.length > 30 ? artist.substring(0, 30) + "..." : artist
                    }
                    font.pixelSize: artistSize
                    opacity: 0.7
                    color: Appearance.colors.m3on_background
                    elide: Text.ElideRight
                }

                StyledSlider {
                    useAnim: false
                    id: barSlider
                    implicitHeight: sliderHeight
                    icon: ""
                    value: 0
                    Connections {
                        target: Players.active
                        function onPositionChanged() {
                            barSlider.value = (Players.active.position / Players.active.length) * 100
                        }
                        function onPostTrackChanged() {
                            barSlider.value = 0
                            Players.active.position = 0
                        }
                    }
                    Layout.fillWidth: true
                    Layout.rightMargin: 20
                    onMoved: {
                        const active = Players.active
                        if (active?.canSeek && active?.positionSupported)
                            active.position = (value/100) * active.length
                    }
                    Timer {
                        interval: 1000
                        running: Players.active?.playbackState == MprisPlaybackState.Playing
                        repeat: true
                        onTriggered: Players.active?.positionChanged()
                    }
                    // FrameAnimation {
                    //     running:
                    //
                    // }
                }
            }
        }
    }
}
