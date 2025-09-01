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
    Layout.alignment: Qt.AlignHCenter
    radius: 80
    color: Colors.opacify(Appearance.colors.m3background, 0.8)
    implicitHeight: child.implicitHeight + 20
    Layout.minimumWidth: 300
    implicitWidth: child.implicitWidth + 20
    ColumnLayout {
        id: child
        anchors.fill: parent
        anchors.margins: 10
        spacing: 0

        RowLayout {
            spacing: 10
            Layout.fillWidth: true

            ClippingRectangle {
                id: coverParent
                property bool hovered: false
                width: 80; height: 80
                radius: 40
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
                            NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic }
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: Colors.opacify(Appearance.colors.m3surface, coverParent.hovered ? 0.6 : 0)

                    Behavior on color {
                        ColorAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic }
                    }
                }

                MaterialIcon {
                    icon: Players.active?.isPlaying ? "play_arrow" : "pause"
                    color: Appearance.colors.m3on_surface
                    font.pixelSize: 46
                    anchors.centerIn: parent
                    renderType: Text.NativeRendering
                    opacity: coverParent.hovered ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutCubic }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: coverParent.hovered = true
                    onExited: coverParent.hovered = false
                    onClicked: {
                        if (!Players.active) return;
                        
                        if (Players.active.isPlaying) 
                            Players.active.pause();
                        else
                            Players.active.play();
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: {
                        const title = Players.active?.trackTitle ?? "Unknown Title";
                        return title.length > 30 ? title.substring(0, 30) + "..." : title;
                    }
                    font.pixelSize: 16
                    font.bold: true
                    color: Appearance.colors.m3on_background
                    elide: Text.ElideRight
                }
                Text {
                    text: {
                        const artist = Players.active?.trackArtist ?? "Unknown Artist";
                        return artist.length > 30 ? artist.substring(0, 30) + "..." : artist;
                    }
                    font.pixelSize: 12
                    opacity: 0.7
                    color: Appearance.colors.m3on_background
                    elide: Text.ElideRight
                }

                // ts so ahh :wilted-rose:
                StyledSlider {
                    useAnim: false
                    id: barSlider
                    implicitHeight: 20
                    icon: ""
                    value: 0
                    Connections {
                        target: Players.active
                        function onPositionChanged() {
                            barSlider.value = (Players.active.position / Players.active.length) * 100
                            //console.log(barSlider.value)
                        }

                        function onPostTrackChanged() {
                            barSlider.value = 0
                            Players.active.position = 0 // BRUH
                        }
                    }
                    Layout.fillWidth: true
                    onMoved: {
                        const active = Players.active;
                        if (active?.canSeek && active?.positionSupported)
                            active.position = (value/100) * active.length;
                    }
                    FrameAnimation {
                        running: Players.active?.playbackState == MprisPlaybackState.Playing
                        onTriggered: Players.active?.positionChanged()
                    }
                }
            }
        }
    }
}
